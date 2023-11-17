@isTest(SeeAllData=true)
public class ConcurProcessInvoiceBatchTest {
    
	static testMethod void testConcurProcessing() {
        
		Concur_Batch__c someBatch = new Concur_Batch__c(Batch_ID__c = '9999');
        insert someBatch;
        
        Payment_Shuttle__c shuttleOne = new Payment_Shuttle__c(Invoice_Number__c = 'AAAAA100', Vendor_ID__c = 'TRIS01',
             Intercompany_ID__c = 'ASHRC', Transaction_Amount__c = '400.00', Apply_Date__c = '2023/01/17', 
             Description_1__c = 'Test Description', Description_2__c = 'Test Description 2', Company_ID__c = 'ASH', 
             Account_Code__c = '7020', Department__c = '112', Program__c = '359', Project__c = '000', Other__c = '00',
             Batch__c = '9999', Invoice_Date__c = '2023-01-17', Expense_Year__c = '2023', X1099_Number__c = '7', 
             Concur_Key__c = '4509303', Concur_Id__c = '3049303', Processed__c = false, Source__c = 'Invoice',
             Concur_Batch__c = someBatch.Id);
        
        Payment_Shuttle__c shuttleTwo = new Payment_Shuttle__c(Invoice_Number__c = 'AAAAA100', Vendor_ID__c = 'TRIS01',
             Intercompany_ID__c = 'ASHRC', Transaction_Amount__c = '600.00', Apply_Date__c = '2023/01/17', 
             Description_1__c = 'Test Description', Description_2__c = 'Test Description 2', Company_ID__c = 'ASH', 
             Account_Code__c = '7020', Charitable_Program__c = 'SCELL', Department__c = '112', Program__c = '359', 
             Project__c = '000', Other__c = '00', Batch__c = '9999', Invoice_Date__c = '2023-01-17', Expense_Year__c = '2023', X1099_Number__c = '7', 
             Concur_Key__c = '4509303', Concur_Id__c = '3049303', Processed__c = false, Source__c = 'Invoice', 
             Concur_Batch__c = someBatch.Id);        
        insert shuttleOne;
        insert shuttleTwo;
        
        Test.startTest();
        ConcurProcessInvoiceBatch cpib = new ConcurProcessInvoiceBatch('ASH', someBatch.Id);
        Id jobid = Database.executeBatch(cpib,5);
        Test.stopTest();     
        
        c2g__codaPurchaseInvoice__c someInvoice = [SELECT Id, c2g__OwnerCompany__r.Key__c, c2g__InvoiceDate__c, 
                                                 	c2g__AccountInvoiceNumber__c, Vendor_ID__c, Concur_Key__c, 
                                                   	Concur_Id__c, Source__c, Type__c FROM c2g__codaPurchaseInvoice__c 
                                                	WHERE Concur_Key__c = '4509303'];
        System.assertEquals(someInvoice.c2g__OwnerCompany__r.Key__c, 'ASH');
        //System.assertEquals(someInvoice.c2g__Period__c, actual);
        System.assertEquals(someInvoice.c2g__InvoiceDate__c, Date.newInstance(2023,01,17));
        System.assertEquals(someInvoice.c2g__AccountInvoiceNumber__c, 'AAAAA100');
        System.assertEquals(someInvoice.Vendor_ID__c, 'TRIS01');
        System.assertEquals(someInvoice.Concur_Key__c, '4509303');
        System.assertEquals(someInvoice.Concur_Id__c, '3049303');
        System.assertEquals(someInvoice.Source__c, 'Concur');
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        
		c2g__codaPurchaseInvoiceExpenseLineItem__c line1 = [SELECT Id, c2g__GeneralLedgerAccount__c, c2g__Dimension1__c, 
                                                           c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, 
                                                           c2g__LineDescription__c, c2g__NetValue__c FROM c2g__codaPurchaseInvoiceExpenseLineItem__c 
                                                           WHERE c2g__NetValue__c = 400.00 AND c2g__PurchaseInvoice__c = :someInvoice.Id];

		c2g__codaPurchaseInvoiceExpenseLineItem__c line2 = [SELECT Id, c2g__GeneralLedgerAccount__c, c2g__Dimension1__c, 
                                                           c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, 
                                                           c2g__LineDescription__c, c2g__NetValue__c FROM c2g__codaPurchaseInvoiceExpenseLineItem__c 
                                                           WHERE c2g__NetValue__c = 600.00 AND c2g__PurchaseInvoice__c = :someInvoice.Id];    
        System.assertEquals(provider.getGlaCode('4199'), line2.c2g__GeneralLedgerAccount__c);
        System.assertEquals(provider.getDimension1('310'), line2.c2g__Dimension1__c);
        System.assertEquals(provider.getDimension2('379'), line2.c2g__Dimension2__c);
        System.assertEquals(provider.getDimension3('000'), line2.c2g__Dimension3__c);
        System.assertEquals(provider.getDimension4('24'), line2.c2g__Dimension4__c);
    }
}