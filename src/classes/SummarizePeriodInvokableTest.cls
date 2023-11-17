@isTest(SeeAllData=true)
public class SummarizePeriodInvokableTest {
    
	public static testmethod void testBatchable() {

		Test.StartTest();
	    List<String> params = new List<String>();
     	params.add('ASH');
        params.add('202398');
        params.add('202401');
        params.add('Opening');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
     	SummarizePeriodInvokable.invokeSummarizePeriod(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'SummarizePeriodBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}   
}