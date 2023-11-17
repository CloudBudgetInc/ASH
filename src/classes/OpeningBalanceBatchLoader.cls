global class OpeningBalanceBatchLoader implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);
        List<PerPost__c> perPostParams = PerPost__c.getall().values();
		String perPostSource = String.valueOf(perPostParams[0].PerPostSource__c);        
        
		String query = 'SELECT Id, Acct__c, Cmpny__c, Balance__c, RefNbr__c, ' + 
        'Sub__c, Transaction_Date__c, Transaction_Type__c, Transaction_Desc__c, PerPost__c ' + 
        'FROM Transaction_Import__c ' + 
        'WHERE Processed__c = false ' + 
        'AND Cmpny__c = :companyKey ' + 
        'AND PerPost__c = :perPostSource';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Transaction_Import__c> scope) {

   		FfaDataProvider provider = FfaDataProvider.getInstance();
		Transaction_Import__c sample = scope.get(0);
        System.debug('Sample: ' + sample);
        Id thisCompanyId = provider.getCompany(sample.Cmpny__c);
        
		List<Transaction_Import__c> knockdowns = new List<Transaction_Import__c>();
		List<c2g__codaJournalLineItem__c> forInsert = new List<c2g__codaJournalLineItem__c>();

        c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
        thisJournal = new c2g__codaJournal__c();
        thisJournal.c2g__Type__c = 'Manual Journal';
        thisJournal.c2g__OwnerCompany__c = provider.getCompany(sample.Cmpny__c);
        thisJournal.c2g__DeriveCurrency__c = true;
        thisJournal.c2g__DerivePeriod__c = false;
        c2g__codaPeriod__c somePeriod = provider.getPeriod(sample.Cmpny__c, sample.PerPost__c);  
        System.debug(somePeriod);
        thisJournal.c2g__Period__c = somePeriod.Id;
        thisJournal.c2g__JournalDate__c = somePeriod.c2g__EndDate__c;
        thisJournal.Migration__c = true;
        Datetime now = System.now();
        thisJournal.c2g__JournalDescription__c = 'Opening Balance - ' + somePeriod.PerPost__c;
        System.debug('Inserting parent journal.');
        insert thisJournal;
        
        for(Transaction_Import__c tx : scope) {

          	Decimal value = 0.00;
           	value = tx.Balance__c;
            String subaccount = tx.Sub__c;
            System.debug('Subaccount is ' + subaccount);
            if(subaccount == '0') { subaccount = '10000000000'; }
    		String dim1Code = subaccount.substring(0,3);
    		String dim2Code = subaccount.substring(3,6);
    		String dim3Code = subaccount.substring(6,9);
    		String dim4Code = subaccount.substring(9,11);
            
            System.debug('Crafting line');
		    c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();
		    journalLine.c2g__Journal__c = thisJournal.Id;
		    String accountCode = tx.Acct__c;
		    if(accountCode == '0' || accountCode == '000000') accountCode = '0000';
		    Id accountCodeResult = provider.getGlaCode(accountCode);
		    if(accountCodeResult == null) { 
		        System.debug(accountCode + ' was null.');
		        accountCode = '0000';
		    }
		    journalLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode(accountCode);
		    journalLine.c2g__Dimension1__c = provider.getDimension1(dim1Code);
		    journalLine.c2g__Dimension2__c = provider.getDimension2(dim2Code);
		    journalLine.c2g__Dimension3__c = provider.getDimension3(dim3Code);
		    journalLine.c2g__Dimension4__c = provider.getDimension4(dim4Code);
		    journalLine.c2g__Value__c = value;
		    journalLine.c2g__LineType__c = 'General Ledger Account';
		    journalLine.c2g__LineDescription__c = 'Opening Balance Migration';

		    forInsert.add(journalLine);
            tx.Processed__c = true;
		    knockdowns.add(tx);
            System.debug('Done adding line and such.');
		}
        System.debug('Done with other stuff.');
		insert forInsert;
		update knockdowns;
	}
	
    public void finish(Database.BatchableContext bc) { }
}