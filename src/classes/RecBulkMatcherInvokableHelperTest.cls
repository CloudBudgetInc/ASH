@isTest(SeeAllData=true)
public class RecBulkMatcherInvokableHelperTest {
    
	public static testmethod void testBatchable() {

		Test.StartTest();
	    List<String> params = new List<String>();
        params.add('ASH');
     	params.add('9876');
        params.add('false');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
     	RecBulkMatcherInvokableHelper.invokeBulkMatching(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ReconciliationBulkMatcherBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}   
}