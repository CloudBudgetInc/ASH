@isTest(SeeAllData=true)
public class Vendor1099ResetBatchTest {
    
	static testMethod void testVendor1099ResetBatch() {   
        
        Test.startTest();
        Vendor1099ResetBatch vendor1099ResetBatch = new Vendor1099ResetBatch('PROM02');
        Id jobId = Database.executeBatch(vendor1099ResetBatch, 1);
        Test.stopTest();
        
        List<Account> vendorAccounts = [SELECT Id, X1099_Processed__c FROM Account WHERE Vendor_ID__c = 'PROM02'];
        Account someAccount = vendorAccounts.get(0);
        System.assertEquals(false, someAccount.X1099_Processed__c);
    }
}