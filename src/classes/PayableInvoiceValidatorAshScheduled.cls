global class PayableInvoiceValidatorAshScheduled implements Schedulable, Database.Batchable<sObject> {
    
   global Database.QueryLocator start(Database.BatchableContext BC) { 

		FfaDataProvider provider = FfaDataProvider.getInstance();
		Id companyId = provider.getCompany('ASH');
       	String invoiceStatus = 'In Progress';

       	String query = 'SELECT Id, c2g__GeneralLedgerAccount__c, c2g__Dimension1__c, c2g__Dimension2__c, ' + 
            'c2g__Dimension3__c, c2g__Dimension4__c, c2g__PurchaseInvoice__r.c2g__OwnerCompany__c, c2g__DestinationCompany__c, c2g__DestinationNetValue__c ' + 
            'FROM c2g__codaPurchaseInvoiceExpenseLineItem__c ' + 
            'WHERE c2g__OwnerCompany__c = :companyId AND ' + 
            'c2g__PurchaseInvoice__r.c2g__InvoiceStatus__c = :invoiceStatus AND ' + 
            'LastModifiedDate = TODAY';
		return Database.getQueryLocator(query);
    }
    
   	global void execute(Database.BatchableContext BC, List<c2g__codaPurchaseInvoiceExpenseLineItem__c> someLines) { 

        System.debug(someLines.size());
        ComboRuleProvider provider = ComboRuleProvider.getInstance();
       	List<c2g__codaPurchaseInvoiceExpenseLineItem__c> linesForUpdate = new List<c2g__codaPurchaseInvoiceExpenseLineItem__c>();
		for( c2g__codaPurchaseInvoiceExpenseLineItem__c someLine : someLines ) {
			boolean valid = true;
            System.debug(someLine.c2g__DestinationNetValue__c);
            System.debug(someLine.c2g__DestinationCompany__c);
            System.debug(someLine.c2g__PurchaseInvoice__r.c2g__OwnerCompany__c);
            if( someLine.c2g__DestinationNetValue__c != null) {
                System.debug('Evaluating as intercompany.');
            	valid = provider.validate(someLine.c2g__DestinationCompany__c,
                	someLine.c2g__GeneralLedgerAccount__c,
                    someLine.c2g__Dimension1__c, 
                    someLine.c2g__Dimension2__c,
                    someLine.c2g__Dimension3__c,
                    someLine.c2g__Dimension4__c);
            } else {
                System.debug('Evaluating as typical company line.');
                valid = provider.validate(someLine.c2g__PurchaseInvoice__r.c2g__OwnerCompany__c, 
                    someLine.c2g__GeneralLedgerAccount__c,
                    someLine.c2g__Dimension1__c, 
                    someLine.c2g__Dimension2__c,
                    someLine.c2g__Dimension3__c, 
                    someLine.c2g__Dimension4__c);
            }
            if( valid == false ) {
            		someLine.Invalid__c = true; 
                    someLine.Validation_Timestamp__c = System.now();
            } else {
            	someLine.Invalid__c = false;
                someLine.Validation_Timestamp__c = System.now();
            } 
            linesForUpdate.add(someLine);
       	}
       	update linesForUpdate;  
   }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new PayableInvoiceValidatorAshScheduled());
    }    
    
    global void finish(Database.BatchableContext bc) { }    
}