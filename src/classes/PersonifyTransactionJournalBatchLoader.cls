global class PersonifyTransactionJournalBatchLoader implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, Bill_To_Name__c, Check_Number__c, Comments__c, CreditDebit__c, Customer_Id__c, ' + 
        'Effective_Date__c, Internal_Account__c, Order_Number__c, Post_Date__c, ' +
		'Receipt_Type_Code__c, Transaction_Amount__c, Transaction_Type__c ' + 
        'FROM Personify_Transaction__c ' + 
		'WHERE Processed__c = false ' + 
        'AND Legacy__c = false ' +
        'AND Patch__c = false';           
       	//'AND Account__c NOT IN (\'1015\', \'1019\')';'
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Personify_Transaction__c> scope) {
        
   		FfaDataProvider provider = FfaDataProvider.getInstance();        
	    List<Personify__c> personifyParams = Personify__c.getall().values();
		String companyKey = String.valueOf(personifyParams[0].Company__c);  
	    String perPost = String.valueOf(personifyParams[0].PerPost__c);
        Id thisCompanyId = provider.getCompany(companyKey);
        
		List<Personify_Transaction__c> knockdowns = new List<Personify_Transaction__c>();
		List<c2g__codaJournalLineItem__c> forInsert = new List<c2g__codaJournalLineItem__c>();
		
		Personify_Transaction__c sample = scope.get(0);        
        c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
        thisJournal.c2g__Type__c = 'Manual Journal';
        thisJournal.c2g__OwnerCompany__c = thisCompanyId;
        thisJournal.c2g__DeriveCurrency__c = true;
        thisJournal.c2g__DerivePeriod__c = false;
        c2g__codaPeriod__c somePeriod = provider.getPeriod(companyKey, perPost);
        thisJournal.c2g__Period__c = somePeriod.Id;
        thisJournal.c2g__JournalDate__c = somePeriod.c2g__StartDate__c;
        thisJournal.Personify_Journal__c = true;
        thisJournal.c2g__JournalDescription__c = 'Personify Transaction Import - ' + somePeriod.c2g__StartDate__c.format();
        insert thisJournal;
        
        for(Personify_Transaction__c tx : scope) {
            
            c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();   
            journalLine.c2g__Journal__c = thisJournal.Id;
            Decimal value = 0.00;
			// Positive debits are unmodified; negative debits essentially become credits. 
			// We flip negative credits positive, thereby turning them into debits			//            
    		if( tx.CreditDebit__c == 'D' ) value = Decimal.valueOf(tx.Transaction_Amount__c); 
    		if( tx.CreditDebit__c == 'C' ) value = (Decimal.valueOf(tx.Transaction_Amount__c) * -1); 
			//System.debug('Value is ' + value);
                     
			String accountString = tx.Internal_Account__c.left(19);
		    String accountCode = accountString.substring(0,4);
    		String dim1Code = accountString.substring(5,8);
    		String dim2Code = accountString.substring(9,12);
            String dim3Code = accountString.substring(13,16);
    		String dim4Code = accountString.substring(17);
            if(dim4Code == '99') { continue; } // safety to prevent accidental import of ASHRC transactions.
		    Id accountCodeResult = provider.getGlaCode(accountCode);
		    journalLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode(accountCode);
		    journalLine.c2g__Dimension1__c = provider.getDimension1(dim1Code);
		    journalLine.c2g__Dimension2__c = provider.getDimension2(dim2Code);
		    journalLine.c2g__Dimension3__c = provider.getDimension3(dim3Code);
		    journalLine.c2g__Dimension4__c = provider.getDimension4(dim4Code);
		    journalLine.c2g__Value__c = value;
		    journalLine.c2g__LineDescription__c = tx.Bill_To_Name__c + ', ' + tx.Customer_Id__c + ', ' + tx.Order_Number__c;       
            journalLine.c2g__LineType__c = 'General Ledger Account';
            forInsert.add(journalLine);
            tx.Processed__c = true;
		    knockdowns.add(tx);
		}
		insert forInsert;
		update knockdowns;
        
        // Balance the journal using a suspense account.
        Id ninety997 = provider.getGlaCode('9997');
        c2g__codaJournal__c outputJournal = [SELECT c2g__Total__c from c2g__codaJournal__c 
                                           WHERE Id = :thisJournal.Id LIMIT 1];
        c2g__codaJournalLineItem__c balancingLine = new c2g__codaJournalLineItem__c();   
        balancingLine.c2g__Journal__c = thisJournal.Id;
        balancingLine.c2g__GeneralLedgerAccount__c = ninety997;
        balancingLine.c2g__Value__c = (outputJournal.c2g__Total__c * -1);
        balancingLine.c2g__LineType__c = 'General Ledger Account';        
        balancingLine.c2g__LineDescription__c = 'Balancing entry'; 
        insert balancingLine;
	}
	
    public void finish(Database.BatchableContext bc) {}
}