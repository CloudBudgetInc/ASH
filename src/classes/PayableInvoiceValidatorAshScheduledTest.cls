@isTest(SeeAllData=true)
public class PayableInvoiceValidatorAshScheduledTest {

    static testMethod void testBadBatch() {
        
		FfaDataProvider provider = FfaDataProvider.getInstance();
       	c2g__codaPeriod__c period = provider.getPeriod('ASH', '202402');
       	String invoiceStatus = 'In Progress';
        
        c2g__codaPurchaseInvoice__c someInvoice = new c2g__codaPurchaseInvoice__c ();
        someInvoice.c2g__OwnerCompany__c = provider.getCompany('ASH');        
        someInvoice.c2g__InvoiceStatus__c = 'In Progress';
        someInvoice.c2g__Period__c = period.Id;
        someInvoice.c2g__InvoiceDescription__c  = 'Test Invoice 999';
        someInvoice.c2g__DeriveCurrency__c = true;
        someInvoice.c2g__InvoiceDate__c = Date.today();
        someInvoice.c2g__Account__c = provider.getVendor('AMER01').Id;        
        someInvoice.c2g__AccountInvoiceNumber__c = 'Test Invoice - ' + Date.today().format();         
        insert someInvoice;
        
        c2g__codaPurchaseInvoiceExpenseLineItem__c someLine = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
        someLine.c2g__PurchaseInvoice__c  = someInvoice.Id;
        someLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        someLine.c2g__Dimension1__c = provider.getDimension1('100');
        someLine.c2g__Dimension2__c = provider.getDimension2('000');
        someLine.c2g__Dimension3__c = provider.getDimension3('000');
        someLine.c2g__Dimension4__c = provider.getDimension4('00');
        someLine.c2g__LineDescription__c = 'Test Entry';
        someLine.c2g__NetValue__c = 100;
        insert someLine;
        
        c2g__codaPurchaseInvoiceExpenseLineItem__c anotherLine = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
        anotherLine.c2g__PurchaseInvoice__c  = someInvoice.Id;
        anotherLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        anotherLine.c2g__Dimension1__c = provider.getDimension1('100');
        anotherLine.c2g__Dimension2__c = provider.getDimension2('000');
        anotherLine.c2g__Dimension3__c = provider.getDimension3('000');
        anotherLine.c2g__Dimension4__c = provider.getDimension4('00');
        anotherLine.c2g__LineDescription__c = 'Test Entry';
        anotherLine.c2g__NetValue__c = 100;
        anotherLine.c2g__DestinationCompany__c = provider.getCompany('ASHRC');
        anotherLine.c2g__DestinationNetValue__c = 100.00;
        insert anotherLine;    

        Test.startTest();
        PayableInvoiceValidatorAshScheduled pivs = new PayableInvoiceValidatorAshScheduled();
        Id jobid = Database.executeBatch(pivs,2);
        Test.stopTest();
        
        List<c2g__codaPurchaseInvoiceExpenseLineItem__c> badLines = [SELECT Id FROM c2g__codaPurchaseInvoiceExpenseLineItem__c  
        	WHERE c2g__PurchaseInvoice__r.c2g__InvoiceDescription__c = 'Test Invoice 999' AND Invalid__c = true];
        System.assertEquals(2, badLines.size());
    }
    
    static testMethod void testGoodBatch() {
           
		FfaDataProvider provider = FfaDataProvider.getInstance();
       	c2g__codaPeriod__c period = provider.getPeriod('ASH', '202402');
       	String journalStatus = 'In Progress';
        
        c2g__codaPurchaseInvoice__c someInvoice = new c2g__codaPurchaseInvoice__c ();
        someInvoice.c2g__OwnerCompany__c = provider.getCompany('ASH');        
        someInvoice.c2g__InvoiceStatus__c = 'In Progress';
        someInvoice.c2g__Period__c = period.Id;
        someInvoice.c2g__InvoiceDescription__c  = 'Test Invoice 998';
        someInvoice.c2g__DeriveCurrency__c = true;
        someInvoice.c2g__InvoiceDate__c = Date.today();
        someInvoice.c2g__Account__c = provider.getVendor('AMER01').Id;        
        someInvoice.c2g__AccountInvoiceNumber__c = 'Test Invoice - ' + Date.today().format();           
        insert someInvoice;
        
        c2g__codaPurchaseInvoiceExpenseLineItem__c someLine = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
        someLine.c2g__PurchaseInvoice__c  = someInvoice.Id;
        someLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        someLine.c2g__Dimension1__c = provider.getDimension1('112');
        someLine.c2g__Dimension2__c = provider.getDimension2('359');
        someLine.c2g__Dimension3__c = provider.getDimension3('000');
        someLine.c2g__Dimension4__c = provider.getDimension4('00');
        someLine.c2g__LineDescription__c = 'Test Entry';
        someLine.c2g__NetValue__c = 100;
        insert someLine;
        
        c2g__codaPurchaseInvoiceExpenseLineItem__c anotherLine = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
        anotherLine.c2g__PurchaseInvoice__c  = someInvoice.Id;
        anotherLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        anotherLine.c2g__Dimension1__c = provider.getDimension1('112');
        anotherLine.c2g__Dimension2__c = provider.getDimension2('459');
        anotherLine.c2g__Dimension3__c = provider.getDimension3('000');
        anotherLine.c2g__Dimension4__c = provider.getDimension4('00');
        anotherLine.c2g__LineDescription__c = 'Test Entry';
        anotherLine.c2g__NetValue__c = 100;
        anotherLine.c2g__DestinationCompany__c = provider.getCompany('ASHRC');
        anotherLine.c2g__DestinationNetValue__c = 100.00;
        insert anotherLine;          
        
        Test.startTest();
        PayableInvoiceValidatorAshScheduled pivs = new PayableInvoiceValidatorAshScheduled();
        Id jobid = Database.executeBatch(pivs,2);
        Test.stopTest();
        
        List<c2g__codaPurchaseInvoiceExpenseLineItem__c> goodLines = [SELECT Id FROM c2g__codaPurchaseInvoiceExpenseLineItem__c  
        	WHERE c2g__PurchaseInvoice__r.c2g__InvoiceDescription__c = 'Test Invoice 998' AND Invalid__c = false];
        System.assertEquals(2, goodLines.size());
    }    
    
    static testMethod void testScheduler() { 
        Test.startTest();
		System.schedule('PayableInvoiceValidatorAshScheduled', '0 0 1 * * ?', new PayableInvoiceValidatorAshScheduled());
        Test.stopTest();
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE ApexClass.Name = 'PayableInvoiceValidatorAshScheduled' 
        	AND JobType = 'BatchApex'];        
        System.assert(batchJobs.size() <> 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
        //System.assertEquals('Queued', batchJobs[0].Status, 'Job planned with an unexpected status.');
    }
}