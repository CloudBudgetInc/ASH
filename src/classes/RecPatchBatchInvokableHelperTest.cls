@isTest(SeeAllData=true)
public class RecPatchBatchInvokableHelperTest {
    
	public static testmethod void testBatchable() {

		Test.StartTest();
	    List<String> params = new List<String>();
        params.add('ASH');
        params.add('202302');
     	params.add('1335');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
     	RecPatchBatchInvokableHelper.invokeRecPatching(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ReconciliationsPatchBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}   
}