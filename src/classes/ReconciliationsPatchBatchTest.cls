@isTest(SeeAllData=true)
public class ReconciliationsPatchBatchTest {
	
    static testMethod void testReconciliationsPatchBatch() { 

		Test.startTest();
        ReconciliationsPatchBatch rbpb = new ReconciliationsPatchBatch('ASH', '202202', '1343');
        Id jobId = Database.executeBatch(rbpb, 1);
        Test.stopTest();

        List<Personify_Transaction__c> results = [SELECT Id FROM Personify_Transaction__c 
        	WHERE CreatedDate = TODAY AND Patch__c = true];
        System.assert(results.size() > 0);
    }
}