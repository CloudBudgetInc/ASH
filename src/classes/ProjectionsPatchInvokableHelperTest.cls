@isTest(SeeAllData=true)
public class ProjectionsPatchInvokableHelperTest {
    
	public static testmethod void testBatchable() {

		Test.StartTest();
	    List<String> params = new List<String>();
     	params.add('ASH');
        params.add('2025');
        params.add('202509');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
     	ProjectionsPatchInvokableHelper.invokeProjectionsPatch(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ProjectionsPatchBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}
}