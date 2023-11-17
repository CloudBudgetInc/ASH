global class PersonifyCashBatchLoader implements Database.Batchable<sObject> {
	
    // NOTE: This batch needs to be run with a large batch size - large enough to cover all 
    // incoming cash records. A batch size of 1000+ has proved successful. This will 'cap' 
    // the number of journals to be aligned with the days of the month. Otherwise this process 
    // will loop 5 or 6 times (or more) and create potentially dozens of unnecessary journals.
    // EXAMPLE:
    // Id batchJobId = Database.executeBatch(new PersonifyCashBatchLoader(),1250);
    // END COMMENT.
	global Database.QueryLocator start(Database.BatchableContext BC) {
	    List<Personify__c> personifyParams = Personify__c.getall().values();
		String bankKey = String.valueOf(personifyParams[0].Bank_Key__c);          
		String query = 'SELECT Id, Check_Number__c, Comments__c, CreditDebit__c, Customer_Id__c, ' + 
        'Effective_Date__c, Internal_Account__c, Order_Number__c, Post_Date__c, ' +
		'Receipt_Type_Code__c, Transaction_Amount__c, Transaction_Type__c ' + 
        'FROM Personify_Transaction__c ' + 
        'WHERE Account__c IN (:bankKey) ' + 
		'AND Processed__c = false ' + 
        'ORDER BY Effective_Date__c ASC';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Personify_Transaction__c> scope) {
        
   		FfaDataProvider provider = FfaDataProvider.getInstance();        
	    List<Personify__c> personifyParams = Personify__c.getall().values();
		String companyKey = String.valueOf(personifyParams[0].Company__c);  
	    String perPost = String.valueOf(personifyParams[0].PerPost__c);
        Id thisCompanyId = provider.getCompany(companyKey);
        c2g__codaPeriod__c thisPeriod = provider.getPeriod(companyKey, perPost);
        
		List<Personify_Transaction__c> knockdowns = new List<Personify_Transaction__c>();
		List<c2g__codaJournalLineItem__c> forInsert = new List<c2g__codaJournalLineItem__c>();

        // Start and end dates for the period for which we're running this cash routine.
		Date startDate = thisPeriod.c2g__StartDate__c;
        Date endDate = thisPeriod.c2g__EndDate__c;
		
        // The following will create a series of journals, one for each day in the period/month. 
        // This is necessary because the cash matching feature looks at the journal date to match
        // on bank transactions! So any attempt to 'simplify' this code will break cash matching.
		Personify_Transaction__c sample = scope.get(0);        
		List<c2g__codaJournal__c> journalsForInsert = new List<c2g__codaJournal__c>();
        for(Date someDate=startDate; someDate <= endDate; someDate=someDate.addDays(1)) {
        	c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
        	thisJournal.c2g__Type__c = 'Manual Journal';
        	thisJournal.c2g__OwnerCompany__c = thisCompanyId;
            thisJournal.c2g__DeriveCurrency__c = true;
            thisJournal.c2g__DerivePeriod__c = false;
        	c2g__codaPeriod__c somePeriod = provider.getPeriod(companyKey, perPost);
        	thisJournal.c2g__Period__c = somePeriod.Id;
        	thisJournal.c2g__JournalDate__c = someDate;
        	thisJournal.c2g__JournalDescription__c = 'Personify Cash Activity - ' + someDate.format();
            thisJournal.Personify_Journal__c = true;
            journalsForInsert.add(thisJournal);
        }
        
        insert journalsForInsert;
        
        Map<String, c2g__codaJournal__c> journalMap = new Map<String, c2g__codaJournal__c>();
        List<c2g__codaJournal__c> journals = [SELECT Id, c2g__JournalDate__c FROM c2g__codaJournal__c 
                                             WHERE c2g__JournalDescription__c LIKE 'Personify Cash Activity%' 
                                             AND Personify_Journal__c = true
                                             AND c2g__OwnerCompany__c = :thisCompanyId 
                                             AND CreatedDate = TODAY];
        
        // Stash all the journals into a map, keyed by day/date.
        for( c2g__codaJournal__c someJournal : journals ) {
            System.debug(someJournal.c2g__JournalDate__c.format());
            journalMap.put(someJournal.c2g__JournalDate__c.format(), someJournal);
        }
        
        for(Personify_Transaction__c tx : scope) {
            c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();
            String dateKey = tx.Effective_Date__c.format();
            c2g__codaJournal__c someParentJournal = journalMap.get(dateKey);
            if(someParentJournal != null ) {
            	journalLine.c2g__Journal__c = someParentJournal.Id;
            }
            else {
                System.debug('No parent journal found.');
                continue;
            }
          	
            Decimal value = 0.00;
			// Positive debits are unmodified; negative debits essentially become credits. 
			// We flip negative credits positive, thereby turning them into debits			//            
    		if( tx.CreditDebit__c == 'D' ) value = Decimal.valueOf(tx.Transaction_Amount__c); 
    		if( tx.CreditDebit__c == 'C' ) value = (Decimal.valueOf(tx.Transaction_Amount__c) * -1);
			String accountString = tx.Internal_Account__c.left(19);
		    String accountCode = accountString.substring(0,4);
    		String dim1Code = accountString.substring(5,8);
    		String dim2Code = accountString.substring(9,12);
            String dim3Code = accountString.substring(13,16);
    		String dim4Code = accountString.substring(17);
		    journalLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode(accountCode);
		    journalLine.c2g__Dimension1__c = provider.getDimension1(dim1Code);
		    journalLine.c2g__Dimension2__c = provider.getDimension2(dim2Code);
		    journalLine.c2g__Dimension3__c = provider.getDimension3(dim3Code);
		    journalLine.c2g__Dimension4__c = provider.getDimension4(dim4Code);
		    journalLine.c2g__Value__c = value;
            if(tx.Check_Number__c != null && tx.Check_Number__c == 'NULL') {
                journalLine.c2g__LineDescription__c = 'No check number.';
            } else {
                journalLine.c2g__LineDescription__c = tx.Check_Number__c;
            }
            journalLine.c2g__LineType__c = 'Bank Account';
            journalLine.c2g__BankAccount__c = provider.getBankAccount(accountCode);
            tx.Processed__c = true;
            forInsert.add(journalLine);   
		    knockdowns.add(tx);
		}
		insert forInsert;
		update knockdowns;     
	}
	
    public void finish(Database.BatchableContext bc) {}
}