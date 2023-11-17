@isTest(SeeAllData=true)
public class RemitAdviceBatchTest {
    
	static testMethod void testRemitAdvice() {
            
    	Test.startTest();
        RemitAdviceBatch rab = new RemitAdviceBatch();
        Id jobid = Database.executeBatch(rab, 1);
        Test.stopTest();

        List<Remit_Advice__c> remitAdvice = [SELECT Id FROM Remit_Advice__c WHERE CreatedDate = TODAY];
        System.assert(remitAdvice.size() > 0);
    }
    
    static testMethod void testScheduler() { 
        Test.startTest();
		System.schedule('RemitAdviceBatchScheduler', '0 0 1 * * ?', new RemitAdviceBatch());
        Test.stopTest();
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE ApexClass.Name = 'RemitAdviceBatch' 
        	AND JobType = 'BatchApex' AND Status = 'Queued'];        
        System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
        System.assertEquals('Queued', batchJobs[0].Status, 'Job planned with an unexpected status.');
    }
}