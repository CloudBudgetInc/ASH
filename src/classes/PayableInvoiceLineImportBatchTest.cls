@isTest(seeAllData=true)
public class PayableInvoiceLineImportBatchTest {

    static testMethod void mainTest(){
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        c2g__codaPurchaseInvoice__c somePin = new c2g__codaPurchaseInvoice__c();
        somePin.c2g__Account__c = provider.getVendor('TRIS01').Id;
        somePin.c2g__AccountInvoiceNumber__c = 'BBBBBBBB';
        somePin.Reference_Number__c = 'A39489GGHT';
        somePin.Batch_Number__c = 'AAAAAAAA';
        somePin.c2g__InvoiceDate__c = Date.newInstance(2021,09,17);
        somePin.c2g__OwnerCompany__c = provider.getCompany('ASH');
        somePin.Source__c = 'Migration';
        insert somePin;        
        
        Payable_Invoice_Line_Import__c someImport = new Payable_Invoice_Line_Import__c();
        someImport.Account__c = '7020';
        someImport.BatNbr__c = 'EEERTOROW';
        someImport.BoxNbr__c ='7';
        someImport.Company__c = 'ASH';
        someImport.LineId__c = '999';
        someImport.RefNbr__c = 'A39489GGHT';
        someImport.Subaccount__c = '11235900000';
        someImport.TranAmt__c = 345.67;
		someImport.TranDesc__c = 'Joey\'s Famous Coffee Snacks';        
        insert someImport;
        Test.startTest();
        PayableInvoiceLineImportBatch pilib = new PayableInvoiceLineImportBatch();
        Id jobid = Database.executeBatch(pilib,5);
        Test.stopTest();
        c2g__codaPurchaseInvoiceExpenseLineItem__c someLine = [SELECT Id, c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c, LineId__c , 
                                               c2g__NetValue__c, c2g__Dimension1__r.c2g__ReportingCode__c, c2g__Dimension2__c, c2g__Dimension3__c,  
                                               c2g__Dimension4__c, Reference_Number__c
                                               FROM c2g__codaPurchaseInvoiceExpenseLineItem__c 
                                               WHERE LineId__c = '999'];
        system.assertEquals('7020', someLine.c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c);
        system.assertEquals(345.67, someLine.c2g__NetValue__c);
        system.assertEquals('A39489GGHT', someLine.Reference_Number__c);
        system.assertEquals('999', someLine.LineId__c);
        system.assertEquals('112', someLine.c2g__Dimension1__r.c2g__ReportingCode__c);
        
        Payable_Invoice_Line_Import__c refresh = [SELECT Id, Processed__c FROM Payable_Invoice_Line_Import__c WHERE RefNbr__c = 'A39489GGHT'];
        system.assertEquals(true, refresh.Processed__c);
    }
}