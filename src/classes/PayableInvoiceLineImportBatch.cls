global class PayableInvoiceLineImportBatch implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);        
        String query = 'SELECT Account__c, BatNbr__c, BoxNbr__c, Company__c, RefNbr__c, ' + 
            'Subaccount__c, TranAmt__c, LineId__c, TranDate__c, TranDesc__c, VendId__c ' + 
            'FROM Payable_Invoice_Line_Import__c ' +
            'WHERE Processed__c = false ' + 
            'AND Company__c = :companyKey';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<Payable_Invoice_Line_Import__c> someImportLines) {

		FfaDataProvider provider = FfaDataProvider.getInstance();        
        
        Map<String, c2g__codaPurchaseInvoice__c> payableInvoiceLookup = new Map<String, c2g__codaPurchaseInvoice__c>(); 
        Map<Id, c2g__codaPurchaseInvoice__c > somePins = 
            new Map<Id, c2g__codaPurchaseInvoice__c >([SELECT Id, c2g__OwnerCompany__c, 
            	c2g__OwnerCompany__r.Name, Reference_Number__c FROM c2g__codaPurchaseInvoice__c]);
        for( Id someId : somePins.keySet() ) {
            c2g__codaPurchaseInvoice__c somePin = somePins.get(someId);
            String refNumber = somePin.Reference_Number__c;
            payableInvoiceLookup.put(refNumber, somePin);
        }
        
        List<Payable_Invoice_Line_Import__c> forUpdate = new List<Payable_Invoice_Line_Import__c>();
        List<c2g__codaPurchaseInvoiceExpenseLineItem__c> forInsert = new List<c2g__codaPurchaseInvoiceExpenseLineItem__c>();

        for(Payable_Invoice_Line_Import__c someImport : someImportLines) {
            
            c2g__codaPurchaseInvoiceExpenseLineItem__c newLine = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
            c2g__codaPurchaseInvoice__c parentPin = payableInvoiceLookup.get(someImport.RefNbr__c);
            if(parentPin == null ){ 
                someImport.Failed__c = true;
                forUpdate.add(someImport);
                continue;
            }

            newLine.c2g__PurchaseInvoice__c = parentPin.Id;
            newLine.c2g__OwnerCompany__c = parentPin.c2g__OwnerCompany__c;
            newLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode(someImport.Account__c);
            newLine.c2g__Dimension1__c = provider.getDimension1(someImport.Subaccount__c.substring(0,3));
            newLine.c2g__Dimension2__c = provider.getDimension2(someImport.Subaccount__c.substring(3,6));
            newLine.c2g__Dimension3__c = provider.getDimension3(someImport.Subaccount__c.substring(6,9));
            newLine.c2g__Dimension4__c = provider.getDimension4(someImport.Subaccount__c.substring(9,11));    
            newLine.c2g__LineDescription__c = someImport.TranDesc__c ;
            newLine.c2g__NetValue__c = someImport.TranAmt__c;
            newLine.Box_3_7__c = someImport.BoxNbr__c;
            newLine.LineId__c = someImport.LineId__c;
            newLine.Reference_Number__c = someImport.RefNbr__c;
            if(someImport.Company__c == 'ASHRC' && parentPin.c2g__OwnerCompany__r.Name == 'ASH' ) {
                newLine.c2g__DestinationCompany__c = provider.getCompany(someImport.Company__c);
                newLine.c2g__DestinationNetValue__c = someImport.TranAmt__c;
            }
            forInsert.add(newLine);
            
            someImport.Processed__c = true;
            forUpdate.add(someImport);
        }
        
        update forUpdate;
        insert forInsert;
    }
    
    public void finish(Database.BatchableContext bc) { }                                                            
}