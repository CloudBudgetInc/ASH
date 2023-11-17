@isTest(SeeAllData=true)
public class ConcurValidatorInvokableHelperTest {

    public static testmethod void testBatchable() {
    
        Test.StartTest();
        List<String> params = new List<String>();
        params.add('1052');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
        ConcurValidatorInvokableHelper.validateConcurBatch(outerParams);
        Test.StopTest();
        
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                        WHERE ApexClass.Name = 'ConcurValidateBatch' 
                                        AND JobType = 'BatchApex'
                                        AND CreatedDate = TODAY];        
        System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);     
    }
}