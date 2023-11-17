@isTest(SeeAllData=true)
public class ReconciliationMatcherBatchTest {
        
    static testMethod void testPersonifyMatching() { 
        
        Personify_Transaction__c transactionOne = new Personify_Transaction__c( 
        	CreditDebit__c='D', Customer_Id__c='20394030', Effective_Date__c = Date.newInstance(2021,10,21),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999999', Transaction_Amount__c = '987.65');
        Personify_Transaction__c transactionTwo = new Personify_Transaction__c( 
        	CreditDebit__c='C', Customer_Id__c='20394030', Effective_Date__c = Date.newInstance(2021,10,21),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999999', Transaction_Amount__c = '987.65');        
        insert transactionOne;
        insert transactionTwo;
        
        Test.startTest();
        ReconciliationMatcherBatch rmb = new ReconciliationMatcherBatch('9876', 'true');
        Id jobId = Database.executeBatch(rmb, 14);
        Test.stopTest();
        
        // Duo matching test.
        List<Personify_Transaction__c> thoseTransactions = [SELECT Id, Match_Status__c FROM Personify_Transaction__c WHERE Order_Number__c = '1001670999999'];
		System.assert(thoseTransactions.size() == 2);
        Personify_Transaction__c transactionFirst = thoseTransactions.get(0);
        Personify_Transaction__c transactionSecond = thoseTransactions.get(1);
        System.assertEquals('Matched', transactionFirst.Match_Status__c);
        System.assertEquals('Matched', transactionSecond.Match_Status__c);         
    }
}