@isTest(seeAllData=true)
public class SolomonPaymentAssignerBatchTest {
    
	static testMethod void mainTest() {
        Solomon_Payment__c somePayment = new Solomon_Payment__c();
        somePayment.Processed__c = false;
        somePayment.Vendor_ID__c = '1800';
        somePayment.Check_Number__c = '0304922';
        somePayment.Amount__c = 450.00;
        somePayment.Date__c = Date.newInstance(2021, 09, 11);
        insert somePayment;
        Test.startTest();
        SolomonPaymentAssignerBatch spab = new SolomonPaymentAssignerBatch();
        Id jobid = Database.executeBatch(spab,5);
        Test.stopTest();
        String vendorId = '1800';
        Account targetAccount = [SELECT Id from Account WHERE Vendor_Id__c = :vendorId];
        Solomon_Payment__c thePayment = [SELECT Id, Vendor__c FROM Solomon_Payment__c WHERE Vendor_Id__c = :vendorId];
        System.assertEquals(targetAccount.Id, thePayment.Vendor__c);

    }
}