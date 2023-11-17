global class AcctHistBatchLoader implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {

        List<Migration__c> migrationParams = Migration__c.getall().values();
        List<PerPost__c> perPostParams = PerPost__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);        
		String perPost = String.valueOf(perPostParams[0].PerPostSource__c);
        
		String query = 'SELECT Id, Acct__c, Sub__c, Company__c, Amount__c, PerPost__c ' +
            'FROM AcctHistImportPivot__c WHERE Company__c = :companyKey AND ' + 
            'PerPost__c = :perPost AND Amount__c <> 0';
        return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<AcctHistImportPivot__c> scope) {

        FfaDataProvider provider = FfaDataProvider.getInstance();        
        AcctHistImportPivot__c sample = scope.get(0);
    	System.debug(sample);
        
        String accountCode = '2999';
        Id twentyNineNineNine = provider.getGlaCode(accountCode);
         
		List<AcctHistImportPivot__c> knockdowns = new List<AcctHistImportPivot__c>();
		List<c2g__codaJournalLineItem__c> forInsert = new List<c2g__codaJournalLineItem__c>();
        
        c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
		thisJournal.c2g__Type__c = 'Manual Journal';
        thisJournal.c2g__OwnerCompany__c = provider.getCompany(sample.Company__c);
		thisJournal.c2g__DeriveCurrency__c = true;
		thisJournal.c2g__DerivePeriod__c = false;
        c2g__codaPeriod__c somePeriod = provider.getPeriod(sample.Company__c, sample.PerPost__c);  
        thisJournal.c2g__Period__c = somePeriod.Id;
        thisJournal.c2g__JournalDate__c = somePeriod.c2g__EndDate__c;
        thisJournal.Migration__c = true;
		thisJournal.c2g__JournalDescription__c = 'Migration - AcctHist - ' + somePeriod.PerPost__c;
		System.debug('Inserting parent journal.');
		insert thisJournal;                        
        
		for(AcctHistImportPivot__c acctHist : scope) {
          	Decimal value = (acctHist.Amount__c * -1);
			System.debug('Value is ' + value);
			String subaccount = acctHist.Sub__c;
            System.debug('Subaccount is ' + subaccount);
            if(subaccount == '0') { subaccount = '10000000000'; }
    		String dim1Code = subaccount.substring(0,3);
    		String dim2Code = subaccount.substring(3,6);
    		String dim3Code = subaccount.substring(6,9);
    		String dim4Code = subaccount.substring(9,11);
            
            System.debug('Crafting line');
		    c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();
		    journalLine.c2g__Journal__c = thisJournal.Id;
		    journalLine.c2g__GeneralLedgerAccount__c = twentyNineNineNine;
		    journalLine.c2g__Dimension1__c = provider.getDimension1(dim1Code);
		    journalLine.c2g__Dimension2__c = provider.getDimension2(dim2Code);
		    journalLine.c2g__Dimension3__c = provider.getDimension3(dim3Code);
		    journalLine.c2g__Dimension4__c = provider.getDimension4(dim4Code);
            // negative values are debits, positive values are credits.
            journalLine.c2g__Value__c = value;
		    journalLine.c2g__LineType__c = 'General Ledger Account';
		    journalLine.c2g__LineDescription__c = '2099 Balance Migration';

            forInsert.add(journalLine); 
		    acctHist.Processed__c = true;
		    knockdowns.add(acctHist);
		}
		insert forInsert;
		update knockdowns;
	}
	
    public void finish(Database.BatchableContext bc){
        //System.debug(recordsProcessed + ' records processed. Shazam!');
    }
}