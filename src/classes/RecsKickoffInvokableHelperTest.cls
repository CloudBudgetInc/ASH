@isTest(SeeAllData=true)
public class RecsKickoffInvokableHelperTest 
{
	public static testmethod void testBatchable() {

		Test.StartTest();
	    List<String> params = new List<String>();
     	params.add('ASH');
        params.add('202309');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
     	ReconciliationsKickoffInvokableHelper.invokeRecsKickoff(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ReconciliationsKickoffBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}   
}