global class SolomonPaymentAssignerBatch implements Database.Batchable<sObject> {

  	global Database.QueryLocator start(Database.BatchableContext BC) {
                   
        String query = 
            'SELECT Id, Processed__c, Vendor_ID__c ' + 
			'FROM Solomon_Payment__c ' + 
            'WHERE Processed__c = false ' +
			'AND Failed__c = false';
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Solomon_Payment__c> someImports) { 

        Map<String, Account> vendorLookup = new Map<String, Account>();
        Id vendorRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        Map<Id, Account> someVendors = new Map<Id, Account>([SELECT Id, Vendor_ID__c, Officer__c FROM Account WHERE RecordTypeId = :vendorRecordType]);
        for( String key : someVendors.keySet() ) {
            Account someAccount = someVendors.get(key);
            vendorLookup.put(someAccount.Vendor_ID__c, someAccount);
        }    

		List<Solomon_Payment__c> forUpdate = new List<Solomon_Payment__c>();

        for(Solomon_Payment__c someImport : someImports) {
            
            Account someVendor = vendorLookup.get(someImport.Vendor_ID__c);
            if(someVendor==null) {
                someImport.Failed__c = true;
            } else {
                someImport.Vendor__c = someVendor.Id;
            	someImport.Processed__c = true;
            }
            forUpdate.add(someImport);
        }

        update forUpdate;     	   
    }
    
    global void finish(Database.BatchableContext bc) {}       
}