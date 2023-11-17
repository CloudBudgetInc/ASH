@isTest(SeeAllData=true)
public class PrepIncomeStatementBatchInvokerTest {
    
    public static testmethod void testBatchable() {
    
		Test.startTest();
      	List<String> params = new List<String>();
       	params.add('ASH');
        params.add('202302');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
       	PrepIncomeStatementBatchInvoker.invokeIncomeStatementPrep(outerParams);
       	Test.stopTest();  
     
       	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'PrepIncomeStatementBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
       	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
    }
}