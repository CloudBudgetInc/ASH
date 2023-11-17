@isTest(SeeAllData=true)
public class RecMatcherInvokableHelperTest {
    
	public static testmethod void testBatchable() {

		Test.StartTest();
	    List<String> params = new List<String>();
     	params.add('1335');
        params.add('true');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
     	RecMatcherInvokableHelper.invokeMatching(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ReconciliationMatcherBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}   
}