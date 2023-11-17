@isTest(SeeAllData=true)
public class Vendor1099FlushBatchTest {
    
	static testMethod void testVendor1099FlushBatch() {   
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        List<Account> oneAccount = [SELECT Id FROM Account WHERE Vendor_ID__c = 'PROM02'];
        Account thatAccount = oneAccount.get(0);
        
		X1099_Year__c ten99Year = new X1099_Year__c( 
                Tax_Year__c = '2025', 
                Payments__c = 500.00,
                Company__c = provider.getCompany('ASH'),
				Vendor__c = thatAccount.Id );
        insert ten99Year;
        
        Test.startTest();
        Vendor1099FlushBatch vendor1099ResetBatch = new Vendor1099FlushBatch('2025');
        Id jobId = Database.executeBatch(vendor1099ResetBatch, 1);
        Test.stopTest();
        
        List<X1099_Year__c> vendor1099s = [SELECT Id FROM X1099_Year__c WHERE Tax_Year__c = '2025'];
        System.assertEquals(0, vendor1099s.size());
    }
}