global class JournalValidatorAshRcScheduled implements Schedulable, Database.Batchable<sObject> {
    
   global Database.QueryLocator start(Database.BatchableContext BC) { 

		FfaDataProvider provider = FfaDataProvider.getInstance();
		Id companyId = provider.getCompany('ASHRC');
       	String journalStatus = 'In Progress';
       	List<String> ignoreCodes = new List<String>{'2999', '9997'};

       	String query = 'SELECT Id, c2g__Dimension1__c, c2g__Dimension2__c, ' + 
            'c2g__Dimension3__c, c2g__Dimension4__c, c2g__LineType__c, c2g__OwnerCompany__c, c2g__DestinationCompany__c, ' + 
            'c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c ' +
            'FROM c2g__codaJournalLineItem__c ' + 
            'WHERE c2g__OwnerCompany__c = :companyId AND ' + 
            'c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c NOT IN :ignoreCodes AND ' +             
            'c2g__Journal__r.c2g__JournalStatus__c = :journalStatus AND ' + 
            'LastModifiedDate = TODAY';
		return Database.getQueryLocator(query);
    }
    
   	global void execute(Database.BatchableContext BC, List<c2g__codaJournalLineItem__c> someLines) { 

        ComboRuleProvider provider = ComboRuleProvider.getInstance();
       	List<c2g__codaJournalLineItem__c> linesForUpdate = new List<c2g__codaJournalLineItem__c>();
		for( c2g__codaJournalLineItem__c someLine : someLines ) {
			boolean valid = true;
            if( someLine.c2g__LineType__c == 'Intercompany') {
            	valid = provider.validate(someLine.c2g__DestinationCompany__c,
                	someLine.c2g__GeneralLedgerAccount__c,
                    someLine.c2g__Dimension1__c, 
                    someLine.c2g__Dimension2__c,
                    someLine.c2g__Dimension3__c,
                    someLine.c2g__Dimension4__c);
            } else {
                valid = provider.validate(someLine.c2g__OwnerCompany__c, 
                    someLine.c2g__GeneralLedgerAccount__c,
                    someLine.c2g__Dimension1__c, 
                    someLine.c2g__Dimension2__c,
                    someLine.c2g__Dimension3__c, 
                    someLine.c2g__Dimension4__c);
            }
            if( valid == false ) {
            		someLine.Invalid__c = true; 
                    someLine.Validation_Timestamp__c = System.now();
            } else {
            	someLine.Invalid__c = false;
                someLine.Validation_Timestamp__c = System.now();
            } 
            linesForUpdate.add(someLine);
       	}
       	update linesForUpdate;  
   }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new JournalValidatorAshRcScheduled());
    }    
    
    global void finish(Database.BatchableContext bc) { }    
}