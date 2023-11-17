@isTest(SeeAllData=true)
public class PayableJournalFixerScheduledTest {
    
	public static testmethod void testBatchable() {

        FfaDataProvider provider = FfaDataProvider.getInstance();        
        c2g__codaPeriod__c somePreviousPeriod = provider.getPeriod('ASH', '202306');
        
        c2g__codaJournal__c someJournal = new c2g__codaJournal__c();
        someJournal.c2g__JournalStatus__c = 'In Progress';
        someJournal.c2g__OwnerCompany__c = provider.getCompany('ASH');
        someJournal.c2g__Period__c = somePreviousPeriod.Id;
		someJournal.c2g__DerivePeriod__c = false;
        someJournal.c2g__Reference__c = 'PINXX98765';                                                            
        insert someJournal;
        
        Test.startTest();
        Database.executeBatch(new PayableJournalFixerScheduled());
        Test.stopTest();

        c2g__codaJournal__c thisJournal = 
            							[SELECT Id, c2g__Period__c, c2g__Period__r.c2g__StartDate__c, 
                                        c2g__Period__r.c2g__EndDate__c, c2g__Period__r.c2g__Description__c
                                        FROM c2g__codaJournal__c 
        								WHERE CreatedDate = TODAY AND c2g__Reference__c = 'PINXX98765'];       
        System.assert(thisJournal.c2g__Period__r.c2g__StartDate__c <= Date.today());
		System.assert(thisJournal.c2g__Period__r.c2g__EndDate__c >= Date.today());
        System.assert(thisJournal.c2g__Period__r.c2g__Description__c.contains('Trading'));
    }
    
    public static testmethod void testSchedulable() { 
        
        Test.startTest();
		System.schedule('PayableJournalFixerScheduled', '0 0 1 * * ?', new PayableJournalFixerScheduled());
        Test.stopTest();
        
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                        WHERE ApexClass.Name = 'PayableJournalFixerScheduled' AND JobType = 'BatchApex'];        
        System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
        String batchJobStatus = batchJobs[0].Status;
        Boolean statusCheck = batchJobStatus.contains('Queued') || batchJobStatus.contains('Completed');
        System.assert(statusCheck, 'Job planned with an unexpected status.');  
    }
}