global class VoucherImportBatch implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Vendor_ID__c, Voucher_Date__c, Account__c, ' +
            'Subaccount__c, Amount__c, Invoice_Number__c, Company__c ' + 
            'FROM Voucher_Import__c ' + 
            'WHERE Processed__c = false AND Failed__c = false';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<Voucher_Import__c> scope) {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();        
		List<Voucher_Import__c> forUpdate = new List<Voucher_Import__c>();
		List<c2g__codaPurchaseInvoice__c> forInsert = new List<c2g__codaPurchaseInvoice__c>();

        for(Voucher_Import__c someImport : scope) {
            
            c2g__codaPurchaseInvoice__c somePin = new c2g__codaPurchaseInvoice__c();
            Account someVendor = provider.getVendor(someImport.Vendor_ID__c);
            if( someVendor == null ) { 
            	someImport.Failed__c = true;
                someImport.Processed__c = true;
                someImport.Reason__c = 'Vendor not found';
                forUpdate.add(someImport);
                continue;
            }
            somePin.c2g__Account__c = someVendor.Id;
            somePin.c2g__AccountInvoiceNumber__c = someImport.Invoice_Number__c.left(25);
            somePin.c2g__InvoiceDate__c = Date.valueOf(someImport.Voucher_Date__c);
            somePin.c2g__OwnerCompany__c = provider.getCompany(someImport.Company__c);
            somePin.Source__c = 'Import';
            insert somePin;

            c2g__codaPurchaseInvoiceExpenseLineItem__c someLine = new c2g__codaPurchaseInvoiceExpenseLineItem__c();            
            someLine.c2g__PurchaseInvoice__c = somePin.Id;
            someLine.c2g__OwnerCompany__c = somePin.c2g__OwnerCompany__c;
            someLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode(someImport.Account__c);
            someLine.c2g__Dimension1__c = provider.getDimension1(someImport.Subaccount__c.substring(0,3));
            someLine.c2g__Dimension2__c = provider.getDimension2(someImport.Subaccount__c.substring(3,6));
            someLine.c2g__Dimension3__c = provider.getDimension3(someImport.Subaccount__c.substring(6,9));
            someLine.c2g__Dimension4__c = provider.getDimension4(someImport.Subaccount__c.substring(9,11));    
            someLine.c2g__LineDescription__c = someImport.Invoice_Number__c ;
            someLine.c2g__NetValue__c = someImport.Amount__c;       
            insert someLine;
        
            // Mark the import as processed and add to the updates batch.
            someImport.Processed__c = true;
            forUpdate.add(someImport);
        }

        update forUpdate;
    }
    
    public void finish(Database.BatchableContext bc) {}    

}