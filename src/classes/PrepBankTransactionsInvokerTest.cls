@isTest(SeeAllData=true)
public class PrepBankTransactionsInvokerTest {
    public static testmethod void testBatchable() {
    
		Test.startTest();
      	List<String> params = new List<String>();
        FfaDataProvider provider = FfaDataProvider.getInstance();
		c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202208');
		Id someGlCode = provider.getGlaCode('1016');
       	params.add(somePeriod.Id);
        params.add(someGlCode);
        params.add('1000');
        List<List<String>> outerParams = new List<List<String>>();
        outerParams.add(params);
       	PrepBankTransactionsInvoker.invokePrepBankTransactions(outerParams);
       	Test.stopTest();  
     
       	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'PrepBankTransactionsBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY]; 
       	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
    }
}