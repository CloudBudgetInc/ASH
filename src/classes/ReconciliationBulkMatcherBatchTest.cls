@isTest(SeeAllData=true)
public class ReconciliationBulkMatcherBatchTest {
      
    // Test 2-way matching with customer/order matching enabled.    
    static testMethod void testPersonifyFullMatching() { 
        
        Personify_Transaction__c transactionOne = new Personify_Transaction__c(Company__c = 'ASH', 
          CreditDebit__c='D', Customer_Id__c='999EGTH123', Effective_Date__c = Date.newInstance(2021,10,21),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999999', Transaction_Amount__c = '987.65');
        Personify_Transaction__c transactionTwo = new Personify_Transaction__c(Company__c = 'ASH', 
          CreditDebit__c='C', Customer_Id__c='999EGTH123', Effective_Date__c = Date.newInstance(2021,10,21),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999999', Transaction_Amount__c = '987.65');        
        insert transactionOne;
        insert transactionTwo;
      
        Test.startTest();
        ReconciliationBulkMatcherBatch rbmb = new ReconciliationBulkMatcherBatch('ASH', '9876', 'false');
        Id jobId = Database.executeBatch(rbmb, 2);
        Test.stopTest();

        List<Personify_Transaction__c> moreTransactions = [SELECT Id, Match_Status__c, Matched_Transaction__c,
                                                           Personify_Match__c
                                                           FROM Personify_Transaction__c 
                                                           WHERE Order_Number__c = '1001670999999'];
        Personify_Transaction__c transaction1 = moreTransactions.get(0);
        Personify_Transaction__c transaction2 = moreTransactions.get(1);      
        System.assertEquals('Matched', transaction1.Match_Status__c);
        System.assertEquals('Matched', transaction2.Match_Status__c);
        System.assertEquals(transaction1.Personify_Match__c, transaction2.Personify_Match__c);  
    }

  	// Test 3-way matching with order matching disabled.  
    static testMethod void testPersonifyCustNumMatching() {   
  
        Personify_Transaction__c transactionThree = new Personify_Transaction__c(Company__c = 'ASH', 
          CreditDebit__c='D',  Customer_Id__c='998EZTH123', Effective_Date__c = Date.newInstance(2021,10,25),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999653', 
      Transaction_Amount__c = '1000' );
        Personify_Transaction__c transactionFour = new Personify_Transaction__c(Company__c = 'ASH', 
          CreditDebit__c='C', Customer_Id__c='998EZTH123', Effective_Date__c = Date.newInstance(2021,10,25),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999998', 
      Transaction_Amount__c = '500');        
        Personify_Transaction__c transactionFive = new Personify_Transaction__c(Company__c = 'ASH', 
          CreditDebit__c='C', Customer_Id__c='998EZTH123', Effective_Date__c = Date.newInstance(2021,10,25),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999998', 
      Transaction_Amount__c = '500');        
        insert transactionThree;
        insert transactionFour;
        insert transactionFive;    
        
        Test.startTest();
        ReconciliationBulkMatcherBatch rbmb = new ReconciliationBulkMatcherBatch('ASH', '9876', 'true');
        Id jobId = Database.executeBatch(rbmb, 3);
        Test.stopTest();        

        List<Personify_Transaction__c> moreTransactions = [SELECT Id, Match_Status__c, Matched_Transaction__c, 
                                                           Personify_Match__c
                                                           FROM Personify_Transaction__c 
                                                           WHERE Customer_Id__c = '998EZTH123'];
        Personify_Transaction__c transaction3 = moreTransactions.get(0);
        Personify_Transaction__c transaction4 = moreTransactions.get(1);
        Personify_Transaction__c transaction5 = moreTransactions.get(2);        
        System.assertEquals(transaction3.Personify_Match__c, transaction4.Personify_Match__c);
        System.assertEquals(transaction4.Personify_Match__c, transaction5.Personify_Match__c);
        System.assertEquals('Matched', transaction3.Match_Status__c);
        System.assertEquals('Matched', transaction4.Match_Status__c);        
        System.assertEquals('Matched', transaction5.Match_Status__c);      
    }
    
    // Verify that non-matching transactions aren't matched.
    static testMethod void negativeTest() {
        Personify_Transaction__c transactionSix = new Personify_Transaction__c(Company__c = 'ASH', 
          	CreditDebit__c='D',  Customer_Id__c='998EZTHZZZ', Effective_Date__c = Date.newInstance(2021,10,25),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999653', 
      		Transaction_Amount__c = '1000' );
        Personify_Transaction__c transactionSeven = new Personify_Transaction__c(Company__c = 'ASH', 
          	CreditDebit__c='C', Customer_Id__c='998EZTHZZZ', Effective_Date__c = Date.newInstance(2021,10,25),
            Internal_Account__c = '9876-100-000-000-00', Order_Number__c = '1001670999998', 
      		Transaction_Amount__c = '500');              
        insert transactionSix;
        insert transactionSeven; 
        
        Test.startTest();
        ReconciliationBulkMatcherBatch rbmb = new ReconciliationBulkMatcherBatch('ASH', '9876', 'false');
        Id jobId = Database.executeBatch(rbmb, 2);
        Test.stopTest();   
        
        List<Personify_Transaction__c> moreTransactions = [SELECT Id, Match_Status__c, Matched_Transaction__c, 
                                                           Personify_Match__c
                                                           FROM Personify_Transaction__c 
                                                           WHERE Customer_Id__c = '998EZTHZZZ'];
        Personify_Transaction__c transaction6 = moreTransactions.get(0);
        Personify_Transaction__c transaction7 = moreTransactions.get(1);       
        System.assertNotEquals('Matched', transaction6.Match_Status__c);
        System.assertNotEquals('Matched', transaction7.Match_Status__c);            
    }
}