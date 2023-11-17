@isTest(SeeAllData=true)
public class PayableInvoiceBatchTest {

    static testMethod void mainTest(){
        Payable_Invoice_Import__c someImport = new Payable_Invoice_Import__c();
        someImport.Batch_Number__c = 'AAAAAAAA';
        someImport.Company__c = 'ASH';
        someImport.Document_Date__c ='2020-07-14 0:00:00';
        someImport.Invoice_Number__c = 'BBBBBBBB';
        someImport.Reference_Number__c = 'CCCCCCCC';
        someImport.Vendor_ID__c = 'TRIS01';
        insert someImport;
        Test.startTest();
        PayableInvoiceImportBatch piib = new PayableInvoiceImportBatch();
        Id jobid = Database.executeBatch(piib,5);
        Test.stopTest();
        c2g__codaPurchaseInvoice__c somePin = [SELECT Id, Batch_Number__c, c2g__InvoiceDate__c, 
                                               c2g__InvoiceStatus__c, c2g__AccountInvoiceNumber__c, 
                                               Reference_Number__c, Source__c
                                               FROM c2g__codaPurchaseInvoice__c 
                                               WHERE Batch_Number__c = 'AAAAAAAA'];
        system.assertEquals('AAAAAAAA', somePin.Batch_Number__c );
        system.assertEquals(Date.valueOf('2020-07-14 0:00:00'), somePin.c2g__InvoiceDate__c );
        system.assertEquals('Migration', somePin.Source__c  );
        system.assertEquals('BBBBBBBB', somePin.c2g__AccountInvoiceNumber__c );
        system.assertEquals('CCCCCCCC', somePin.Reference_Number__c );
        
        Payable_Invoice_Import__c refresh = [SELECT Id,Processed__c FROM Payable_Invoice_Import__c WHERE Reference_Number__c = 'CCCCCCCC'];
        system.assertEquals(true, refresh.Processed__c);
    }
}