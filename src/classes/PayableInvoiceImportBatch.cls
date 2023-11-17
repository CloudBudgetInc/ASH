global class PayableInvoiceImportBatch implements Database.Batchable<sObject> {

  	global Database.QueryLocator start(Database.BatchableContext BC) {
        
	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String company = String.valueOf(migrationParams[0].Company__c);           
        String query = 
            'SELECT Batch_Number__c, Company__c, Document_Date__c, Invoice_Number__c, ' + 
            'Reference_Number__c, Vendor_ID__c ' + 
			'FROM Payable_Invoice_Import__c WHERE Processed__c = false AND Company__c = :company';
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Payable_Invoice_Import__c> someImports) { 
        
        FfaDataProvider provider = FfaDataProvider.getInstance();

        Map<String, Account> vendorLookup = new Map<String, Account>();
        Id vendorRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        Map<Id, Account> someVendors = new Map<Id, Account>([SELECT Id, Vendor_ID__c, Officer__c FROM Account WHERE RecordTypeId = :vendorRecordType]);
        for( String key : someVendors.keySet() ) {
            Account someAccount = someVendors.get(key);
            vendorLookup.put(someAccount.Vendor_ID__c, someAccount);
        }    

		List<Payable_Invoice_Import__c> forUpdate = new List<Payable_Invoice_Import__c>();
		List<c2g__codaPurchaseInvoice__c> forInsert = new List<c2g__codaPurchaseInvoice__c>();

        for(Payable_Invoice_Import__c someImport : someImports) {
            
            c2g__codaPurchaseInvoice__c somePin = new c2g__codaPurchaseInvoice__c();
            somePin.c2g__Account__c = vendorLookup.get(someImport.Vendor_ID__c).Id;
            somePin.c2g__AccountInvoiceNumber__c = someImport.Invoice_Number__c; 
            somePin.Reference_Number__c = someImport.Reference_Number__c;
            somePin.Batch_Number__c = someImport.Batch_Number__c;
            somePin.c2g__InvoiceDate__c = Date.valueOf(someImport.Document_Date__c);
            somePin.c2g__OwnerCompany__c = provider.getCompany(someImport.Company__c);
            somePin.Source__c = 'Migration';
            forInsert.add(somePin);
        
            // Mark the import as processed and add to the updates batch.
            someImport.Processed__c = true;
            forUpdate.add(someImport);
        }

        insert forInsert;
        update forUpdate;     	   
    }
    
    global void finish(Database.BatchableContext bc) {}       
}