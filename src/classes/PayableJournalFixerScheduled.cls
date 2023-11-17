global class PayableJournalFixerScheduled implements Schedulable, Database.Stateful, Database.Batchable<sObject> {
    
    Integer journalCounter = 0;
    
    /**
     * When intercompany journals are generated, the system uses the transactional date to derive the Period.
     * This works great for Journals, forcing us to keep that setting in place. 
     * But for payable invoices, this often means the journal period isn't accurately set as the transactional 
     * date only rarely aligns with the desired Period.
     * 
     * This class runs on a scheduled basis, updating the journal Period to reflect 'today' which is typically 
     * representative of the desired Period for accounts payable documents. The main exception being 
     * end-of-year scenarios where invoices are purposefully selected for certain fiscal years.
     * 
     * This class should really execute once per day, to clean up the day's generated journals. This class
     * handles journals for both companies, but ASHRC will generate the majority of the interest here as 
     * most intercompany journals land there.
     */
	global Database.QueryLocator start(Database.BatchableContext BC) { 
       
		// Query for intercompany journals of interest using the reference field which will start 
		// with PIN.
		String referenceKey = 'PIN%';
		String status = 'In Progress';
		String query = 'SELECT Id, c2g__OwnerCompany__r.Key__c FROM c2g__codaJournal__c ' + 
            'WHERE c2g__Reference__c LIKE :referenceKey AND ' + 
			'CreatedDate = TODAY AND c2g__JournalStatus__c = :status';
		return Database.getQueryLocator(query);
    }
    
    /**
     * Loop through all of today's PIN-sourced Intercompany Journals, and fix the period. Note that due to 
     * the fact that all batched updates need to be consolidated to a single company, some of the code below
     * is a little odd - separate collections for each company are created, etc. I decided this was better than 
     * having two different classes performing the same function...
     */
   	global void execute(Database.BatchableContext BC, List<c2g__codaJournal__c> someJournals) { 

		List<c2g__codaJournal__c> ashJournalsForUpdate = new List<c2g__codaJournal__c>();
		List<c2g__codaJournal__c> ashRcJournalsForUpdate = new List<c2g__codaJournal__c>();        
        
		String ashCompanyKey = 'ASH';
		c2g__codaPeriod__c ashPeriod = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__Description__c LIKE '%Trading%' 
                                        AND c2g__StartDate__c <= TODAY and c2g__EndDate__c >= TODAY 
                                        AND c2g__OwnerCompany__r.Key__c = :ashCompanyKey];
        
		String ashrcCompanyKey = 'ASHRC';
		c2g__codaPeriod__c ashrcPeriod = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__Description__c LIKE '%Trading%' 
                                        AND c2g__StartDate__c <= TODAY and c2g__EndDate__c >= TODAY 
                                        AND c2g__OwnerCompany__r.Key__c = :ashrcCompanyKey];        

		for( c2g__codaJournal__c someJournal : someJournals ) {
            if(someJournal.c2g__OwnerCompany__r.Key__c == 'ASH') { 
            	someJournal.c2g__Period__c = ashPeriod.Id;
                someJournal.Notes__c = 'Period updated via PayableJournalFixer.';
				ashJournalsForUpdate.add(someJournal);                
            }
            else {
                someJournal.c2g__Period__c = ashRcPeriod.Id;
                someJournal.Notes__c = 'Period updated via PayableJournalFixer.';
                ashRcJournalsForUpdate.add(someJournal);
            }
            journalCounter++;
		}
		update ashJournalsForUpdate;
		update ashRcJournalsForUpdate;
   }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new PayableJournalFixerScheduled());
    }    
    
    global void finish(Database.BatchableContext bc) {
        
        // Check batch status.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, 
                          CreatedBy.Email, ExtendedStatus FROM AsyncApexJob 
                          WHERE Id = :bc.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'rtolocka.itconsultant@hematology.org'};
        mail.setToAddresses(toAddresses);        
        
	  	if(a.NumberOfErrors == 0 && journalCounter > 0) {        
            mail.setSubject('Intercompany Journals - Periods were Adjusted');
            mail.setPlainTextBody(journalCounter + ' intercompany journal(s) had their period adjusted.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        else if (a.NumberOfErrors > 0 && journalCounter > 0) {
            mail.setSubject('Intercompany Journals - Period Adjustment Failed');
            mail.setPlainTextBody('Intercompany Journals - Period adjustment failed.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        else if (a.NumberOfErrors == 0 && journalCounter == 0) {
            mail.setSubject('Intercompany Journals - Period Adjustment Ran but No Records Found');
            mail.setPlainTextBody('Intercompany Journals - the process ran but no records were found.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
        }
    }
}