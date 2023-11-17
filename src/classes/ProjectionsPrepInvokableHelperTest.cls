@isTest(SeeAllData=true)
public class ProjectionsPrepInvokableHelperTest {
    
	public static testmethod void testBatchable() {

		Test.StartTest();
	    List<String> params = new List<String>();
     	params.add('ASH');
        params.add('2024');
        params.add('202409');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
     	ProjectionsPrepInvokableHelper.invokeProjectionsPrep(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ProjectionsPrepBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}
}