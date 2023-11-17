@isTest(SeeAllData=true)
public class VendorPrenoterScheduledTest {
    
     public static testmethod void testBatchable() {

        Account someAccount = [SELECT Id FROM Account WHERE Vendor_Id__c = 'BLAC08'];
        someAccount.Prenote_Status__c = 'Pending';
        someAccount.c2g__CODAPaymentMethod__c = 'Check';
        someAccount.Date_of_Prenote_Approval__c = DateTime.newInstance(2021, 01, 01, 00, 00, 00);
        update someAccount;
         
        Test.StartTest();
        Database.executeBatch(new VendorPrenoterScheduled());
        Test.StopTest();  
         
        Account thatAccount = [SELECT Id, Prenote_Status__c, c2g__CODAPaymentMethod__c FROM Account WHERE 
                              Vendor_Id__c = 'BLAC08'];
        System.assertEquals('Approved', thatAccount.Prenote_Status__c);
        System.assertEquals('ACH', thatAccount.c2g__CODAPaymentMethod__c);
     }
    
    private static testmethod void testSchedulable() { 
        Test.startTest();
		System.schedule('Delete Logs Schedulable', '0 0 1 * * ?', new VendorPrenoterScheduled());
        Test.stopTest();
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE ApexClass.Name = 'VendorPrenoterScheduled' AND JobType = 'BatchApex'];        
        System.assertEquals(1, batchJobs.size(), 'Unexpected number of batch jobs ran: ' + batchJobs);
        System.assertEquals('Queued', batchJobs[0].Status, 'Job planned with an unexpected status.');
    } 
}