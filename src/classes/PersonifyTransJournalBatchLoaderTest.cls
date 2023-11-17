@isTest(SeeAllData=true)
public class PersonifyTransJournalBatchLoaderTest {

	static testMethod void testPersonifyBatchUpload() { 
     
        // No adjustment to Custom Settings needed to run this. The batch grabs all 
        // unprocessed transactions.
        Personify_Transaction__c someTransaction = new Personify_Transaction__c( 
        	Check_Number__c='3409403', Comments__c='LB 9478 $2,625.00', CreditDebit__c='D', 
            Customer_Id__c='20394030', Effective_Date__c = Date.newInstance(2023,07,21),
            Internal_Account__c = '1343-100-000-000-00',
            Order_Number__c = '1001670213', Post_Date__c = Date.newInstance(2023,07,21),
			Transaction_Amount__c = '987.65', Transaction_Type__c = 'DP');
        someTransaction.Processed__c = false;
        insert someTransaction;
        
        Test.startTest();
        PersonifyTransactionJournalBatchLoader ptjbl = new PersonifyTransactionJournalBatchLoader();
        Id jobId = Database.executeBatch(ptjbl, 1);
        Test.stopTest();
        
        c2g__codaJournal__c thisJournal = [SELECT Id, c2g__Total__c, c2g__Debits__c, c2g__Credits__c FROM c2g__codaJournal__c 
        	WHERE CreatedDate = TODAY AND c2g__JournalStatus__c = 'In Progress' AND c2g__Debits__c = 987.65];
        System.assertNotEquals(thisJournal, null);
        System.assertEquals(0.00, thisJournal.c2g__Total__c);
    }
}