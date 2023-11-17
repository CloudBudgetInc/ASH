global class BalanceJournalsBatch implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

        /** Unsure why, but it appears intermingled-by-company inserts are not permitted. 
         */
	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);
		FfaDataProvider provider = FfaDataProvider.getInstance();
		Id companyId = provider.getCompany(companyKey);
        String status = 'In Progress';
		String query = 'SELECT Id, c2g__OwnerCompany__c, c2g__Total__c FROM c2g__codaJournal__c ' + 
            'WHERE c2g__JournalStatus__c = :status AND ' + 
            'c2g__OwnerCompany__c = :companyId AND Flag_for_Balance__c = true AND Balanced__c = false';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<c2g__codaJournal__c> scope) {

		Map<Id, c2g__codaGeneralLedgerAccount__c> accountCodes = 
            new Map<Id, c2g__codaGeneralLedgerAccount__c>([SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c]);
		Map<String, Id> glLookup = new Map<String, Id>();
		for( String key : accountCodes.keySet() ) {
		    c2g__codaGeneralLedgerAccount__c blapp = accountCodes.get(key);
		    glLookup.put(blapp.c2g__ReportingCode__c, key);
		}

		List<c2g__codaJournalLineItem__c> linesForInsert = new List<c2g__codaJournalLineItem__c>();

        for(c2g__codaJournal__c someJournal : scope) {

        	c2g__codaJournalLineItem__c newLine = new c2g__codaJournalLineItem__c();
			newLine.c2g__Journal__c = someJournal.Id;
			newLine.c2g__GeneralLedgerAccount__c = glLookup.get('9997');
		    newLine.c2g__LineType__c = 'General Ledger Account';
		    newLine.c2g__LineDescription__c = 'Balancing Entry';
		    Decimal balancingValue = someJournal.c2g__Total__c;

        	if(someJournal.c2g__Total__c <> 0) {
			    newLine.c2g__Value__c = (balancingValue * -1);
        	}
		    linesForInsert.add(newLine);
		}
		insert linesForInsert;
	}
	
    public void finish(Database.BatchableContext bc) {}
}