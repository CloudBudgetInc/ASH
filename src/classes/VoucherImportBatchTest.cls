@isTest(SeeAllData=true)
public class VoucherImportBatchTest {
    
    static testMethod void testVoucherImportBatch1() { 
        
        Voucher_Import__c someVoucherImport = new Voucher_Import__c();
        someVoucherImport.Account__c = '7360';
        someVoucherImport.Amount__c = 500.00;
        someVoucherImport.Company__c = 'ASH';
        someVoucherImport.Invoice_Number__c = 'Miriam Kwarteng-Siaw-AAA-2021';
        someVoucherImport.Subaccount__c = '13535300041';
        someVoucherImport.Vendor_ID__c = 'KWAR01';
        someVoucherImport.Voucher_Date__c = '2022-01-15';
        insert someVoucherImport;
        
        Test.startTest();
        VoucherImportBatch vib = new VoucherImportBatch();
        Id jobId = Database.executeBatch(vib, 1);
        Test.stopTest();                
    }
}