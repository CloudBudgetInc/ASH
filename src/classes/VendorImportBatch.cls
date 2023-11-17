global class VendorImportBatch implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT X1099_Vendor__c, Bank_Account_Number__c, Bank_Name__c, ' + 
            'Bank_Routing_Number__c, Default_Box_Selection__c, IBAN_Number__c, ' + 
            'Intermediary_Bank_Address__c, Intermediary_Bank_Name__c, Intermediary_Bank_SWIFT__c, ' + 
            'International_Subtype__c, Invoice_Email__c, Payment_Method__c, Remit_Address_1__c, ' + 
            'Remit_Address_2__c, Remit_City__c, Remit_Country_Code__c, Remit_Name__c, Remit_Postal_Code__c, ' + 
            'Remit_State__c, SWIFT_Number__c, Tax_ID_Number__c, TIN_Name__c, Vendor_ID__c, Wire_Bank_City__c, ' + 
            'Wire_Bank_Country__c, Wire_Bank_Name__c, Wire_Bank_Postal_Code__c, Wire_Bank_Reference__c, ' + 
            'Wire_Bank_State__c, Wire_Bank_Street__c,Ebanking_Email__c ' +
            'FROM Vendor_Import__c WHERE Processed__c = false and Failed__c = false';
        return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<Vendor_Import__c> scope) {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id vendorRecordTypeId = provider.getVendorRecordTypeId();
        Id glAccount = provider.getGlaCode('2040');
        Id dim1 = provider.getDimension1('100');
        Id dim2 = provider.getDimension2('000');
        Id dim3 = provider.getDimension3('000');
        Id dim4 = provider.getDimension4('00');
        System.debug('1');
        
		// Set up a lookup map to help identify/prevent duplicate vendors.
        List<Account> allVendors = [SELECT Id, Vendor_ID__c FROM Account WHERE RecordType.Id = :vendorRecordTypeId];
        Map<String, Account> vendorLookup = new Map<String, Account>(); 
		for(Account someVendor : allVendors)
        	vendorLookup.put(someVendor.Vendor_ID__c, someVendor);
        
        List<Account> forInsert = new List<Account>();
        List<Vendor_Import__c> forUpdate = new List<Vendor_Import__c>();
        
        for(Vendor_Import__c someImport : scope) {
            Account newVendor = new Account();
            if(vendorLookup.containsKey(someImport.Vendor_ID__c)) {
                someImport.Reason__c = 'Duplicate vendor';
                someImport.Processed__c = true;
                someImport.Failed__c = true;
                forUpdate.add(someImport);
                continue;
            }

			// Basic setup stuff here.
            newVendor.RecordTypeId = vendorRecordTypeId;
            if(someImport.Remit_Name__c != null) { newVendor.Name = someImport.Remit_Name__c; }
            if(someImport.Remit_Name__c != null) { newVendor.Remit_Name__c = someImport.Remit_Name__c; }
            newVendor.Vendor_Status__c = 'Approved';
            if(someImport.Vendor_ID__c != null) { newVendor.Vendor_ID__c = someImport.Vendor_ID__c; }
            if(someImport.Payment_Method__c != null) { newVendor.c2g__CODAPaymentMethod__c = getPaymentMethod(someImport.Payment_Method__c); }
            if(someImport.Remit_Address_1__c != null) { newVendor.Remit_Address_1__c = someImport.Remit_Address_1__c; }
            if(someImport.Remit_Address_2__c != null) { newVendor.Remit_Address_2__c = someImport.Remit_Address_2__c; }
            if(someImport.Remit_City__c != null) { newVendor.Remit_City__c = someImport.Remit_City__c; }
            if(someImport.Remit_State__c != null) { newVendor.Remit_State__c = someImport.Remit_State__c; }
            if(someImport.Remit_Postal_Code__c != null) { newVendor.Remit_Postal_Code__c = someImport.Remit_Postal_Code__c; }
            if(someImport.Remit_Country_Code__c != null) { newVendor.Remit_Country_Code__c = someImport.Remit_Country_Code__c; }
            if(someImport.Default_Box_Selection__c != null) { newVendor.Default_Box_Selection__c = someImport.Default_Box_Selection__c; }
            if(someImport.TIN_Name__c != null) { newVendor.TIN_Name__c = someImport.TIN_Name__c; }
            if(someImport.Tax_ID_Number__c != null) { newVendor.c2g__CODATaxpayerIdentificationNumber__c = someImport.Tax_ID_Number__c; }
            if(someImport.X1099_Vendor__c != null) { 
                if(someImport.X1099_Vendor__c == '1') { 
                	newVendor.c2g__CODAFederallyReportable1099__c = true;
                }
                else { 
                	newVendor.c2g__CODAFederallyReportable1099__c = false;
                }
            }
            if(someImport.Ebanking_Email__c != null && someImport.Ebanking_Email__c != '' && someImport.Ebanking_Email__c != 'NULL') { 
                newVendor.c2g__CODAInvoiceEmail__c = someImport.Ebanking_Email__c;				            
            }
            else if (someImport.Invoice_Email__c != null && someImport.Invoice_Email__c != '') { 
	            newVendor.c2g__CODAInvoiceEmail__c = someImport.Invoice_Email__c;				            
            }
            // basic bank details.
            if(someImport.Bank_Account_Number__c != null) { newVendor.c2g__CODABankAccountNumber__c = someImport.Bank_Account_Number__c; }
            if(someImport.Bank_Routing_Number__c != null) { newVendor.c2g__CODABankSortCode__c = someImport.Bank_Routing_Number__c.left(8); }
            if(someImport.Bank_Routing_Number__c != null) { newVendor.Bank_Check_Digit__c = Decimal.valueOf(someImport.Bank_Routing_Number__c.right(1)); }
            // bank wire details
            if(someImport.SWIFT_Number__c != null) { newVendor.c2g__CODABankSWIFTNumber__c = someImport.SWIFT_Number__c; }
            if(someImport.IBAN_Number__c != null) { newVendor.c2g__CODABankIBANNumber__c = someImport.IBAN_Number__c; }
            if(someImport.International_Subtype__c != null) { newVendor.International_Subtype__c = someImport.International_Subtype__c; }
            // beneficiary bank details
            if(someImport.Wire_Bank_Name__c != null) { newVendor.c2g__CODABankName__c = someImport.Wire_Bank_Name__c; }
            if(someImport.Wire_Bank_Reference__c != null) { newVendor.c2g__CODABankAccountReference__c = someImport.Wire_Bank_Reference__c.left(20); }
            if(someImport.Wire_Bank_Street__c != null) { newVendor.c2g__CODABankStreet__c = someImport.Wire_Bank_Street__c; }
            if(someImport.Wire_Bank_City__c != null) { newVendor.c2g__CODABankCity__c = someImport.Wire_Bank_City__c; }
            if(someImport.Wire_Bank_State__c != null) { newVendor.c2g__CODABankStateProvince__c = someImport.Wire_Bank_State__c; }
            if(someImport.Wire_Bank_Postal_Code__c != null) { newVendor.c2g__CODABankZipPostalCode__c = someImport.Wire_Bank_Postal_Code__c; }
            if(someImport.Wire_Bank_Country__c != null) { newVendor.c2g__CODABankCountry__c = someImport.Wire_Bank_Country__c; }
            // intermediary
            if( newVendor.Intermediataty_Bank_Name__c != null ) { newVendor.Intermediataty_Bank_Name__c = someImport.Intermediary_Bank_Name__c; }
            if( newVendor.Intermediary_Bank_Address__c != null ) { newVendor.Intermediary_Bank_Address__c = someImport.Intermediary_Bank_Address__c; }
            if( newVendor.Intermediary_Bank_SWIFT__c != null ) { newVendor.Intermediary_Bank_SWIFT__c = someImport.Intermediary_Bank_SWIFT__c; }
            // gl codes
            newVendor.c2g__CODAAccountsPayableControl__c = glAccount;
            newVendor.c2g__CODADimension1__c = dim1;
            newVendor.c2g__CODADimension2__c = dim2;
            newVendor.c2g__CODADimension3__c = dim3;
            newVendor.c2g__CODADimension4__c = dim4;
            // credit terms
            newVendor.c2g__CODABaseDate1__c = 'Invoice Date';
            newVendor.c2g__CODADaysOffset1__c = 30;
            // wrap it up.
            someImport.Processed__c = true;
            forUpdate.add(someImport);
            forInsert.add(newVendor);
        }
        
        insert forInsert;
        update forUpdate;
    }
    
    private static String getPaymentMethod(String paymentMethod) {
        if(paymentMethod.indexOf('ACH') > 0) { return 'ACH'; }
        if(paymentMethod.indexOf('IW') > 0) { return 'International Wire'; }
        if(paymentMethod.indexOf('DW') > 0) { return 'Domestic Wire'; }
        return 'Check';
    }
    
    public void finish(Database.BatchableContext bc) {}
}