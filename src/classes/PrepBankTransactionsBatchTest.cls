@isTest(SeeAllData=true)
public class PrepBankTransactionsBatchTest {
    
	public static testmethod void testJournalization() {    
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        c2g__codaPeriod__c period = provider.getPeriod('ASH', '202208');
        Id someGlaCode = provider.getGlaCode('1016');
        
        Test.startTest();
       	Id batchJobId = Database.executeBatch(new PrepBankTransactionsBatch(period.Id, someGlaCode), 1000); 
       	Test.stopTest();  
        
        Id periodId = period.Id;
        List<Bank_Transaction__c> results = [SELECT Id FROM Bank_Transaction__c WHERE CreatedDate = TODAY and Period__c = :periodId];        
        System.assert(results.size() > 0);
    }
}