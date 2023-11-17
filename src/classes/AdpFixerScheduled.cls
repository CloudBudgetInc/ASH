global class AdpFixerScheduled implements Schedulable, Database.Batchable<sObject> {
    
   global Database.QueryLocator start(Database.BatchableContext BC) { 
		       
        String journalDescription = 'ADP Payroll Integration';
       	String journalStatus = 'In Progress';
        String lineType = 'Intercompany';
        String query = 'SELECT Id, c2g__Dimension2__c, c2g__Dimension2__r.c2g__ReportingCode__c, ' + 
            'c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c ' +
            'FROM c2g__codaJournalLineItem__c ' + 
            'WHERE c2g__Journal__r.c2g__JournalDescription__c = :journalDescription AND ' + 
            'c2g__Journal__r.c2g__JournalStatus__c = :journalStatus AND ' + 
            'c2g__LineType__c <> :lineType';
		return Database.getQueryLocator(query);
    }
    
   	global void execute(Database.BatchableContext BC, List<c2g__codaJournalLineItem__c> someLines) { 

        //Map<Id,String> journalTracker = new Map<Id,String>();
        FfaDataProvider provider = FfaDataProvider.getInstance();
       	List<c2g__codaJournalLineItem__c> linesForUpdate = new List<c2g__codaJournalLineItem__c>();
		for( c2g__codaJournalLineItem__c someLine : someLines ) {
			if( someLine.c2g__Dimension2__r.c2g__ReportingCode__c == '392' || 
            	someLine.c2g__Dimension2__r.c2g__ReportingCode__c == '395' ||
              	someLine.c2g__Dimension2__r.c2g__ReportingCode__c == '405' ||
              	someLine.c2g__Dimension2__r.c2g__ReportingCode__c == '480' || 
                (someLine.c2g__Dimension2__r.c2g__ReportingCode__c == '450' && 
                 (someLine.c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c == '9030' || 
                  someLine.c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c == '9035'))) {
					someLine.c2g__DestinationCompany__c = provider.getCompany('ASHRC');
                	someLine.c2g__LineType__c = 'Intercompany';
                	someLine.c2g__DestinationLineType__c = 'General Ledger Account';
	    	   		linesForUpdate.add(someLine);
                    //journalTracker.put(someLine.c2g__Journal__c, 'Processed');
            }
       	}
       	update linesForUpdate;
        
        
        
        
   }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new AdpFixerScheduled());
    }    
    
    global void finish(Database.BatchableContext bc) { }    
}