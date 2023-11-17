@isTest(SeeAllData=true)
public class PersonifyCashBatchLoaderTest {

	static testMethod void testPersonifyCashBatchUpload() { 
     
        // Personify custom settings to Company=ASH, Bank Key=1015, Period to 202401 for test to pass.
        Personify_Transaction__c someTransaction = new Personify_Transaction__c( 
        	Check_Number__c='3409403', Comments__c='LB 9478 $123.45', CreditDebit__c='D', 
            Customer_Id__c='20394030', Effective_Date__c = Date.newInstance(2023,07,21),
            Internal_Account__c = '1015-100-000-000-00', Order_Number__c = '1001670213', 
            Post_Date__c = Date.newInstance(2023,07,21), Transaction_Amount__c = '123.45', 
            Transaction_Type__c = 'DP');
        someTransaction.Processed__c = false;
        insert someTransaction;
        
        Test.startTest();
        PersonifyCashBatchLoader pcbl = new PersonifyCashBatchLoader();
        Id jobId = Database.executeBatch(pcbl, 1);
        Test.stopTest();
        
        c2g__codaJournal__c thisJournal = [SELECT Id, c2g__Debits__c, c2g__Credits__c FROM c2g__codaJournal__c 
        	WHERE CreatedDate = TODAY AND c2g__Debits__c > 0.00];
        System.assertNotEquals(null, thisJournal);
    }
}