@isTest(SeeAllData=true)
public class ProjectionsCloseInvokableHelperTest {
    
	public static testmethod void testBatchable() {

		Test.StartTest();
	    List<String> params = new List<String>();
     	params.add('ASH');
        params.add('2024');
        params.add('202409');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
     	ProjectionsCloseInvokableHelper.invokeProjectionsClose(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ProjectionsCloseBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}   
}