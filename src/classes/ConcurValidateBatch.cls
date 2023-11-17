global class ConcurValidateBatch implements Database.Batchable<sObject> {

    String batchId;    

    public ConcurValidateBatch(String batchId) {
        this.batchId = batchId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Account_Code__c, Department__c, Program__c, Project__c, Invoice_Number__c, ' + 
            'Other__c, Company_ID__c, Intercompany_ID__c, Vendor_ID__c, Failed__c FROM Payment_Shuttle__c ' + 
            'WHERE Concur_Batch__c = :batchId ' + 
            'ORDER BY Vendor_ID__c';
		return Database.getQueryLocator(query);
	}
    	    
    global void execute(Database.BatchableContext BC, List<Payment_Shuttle__c> scope) {

		List<Payment_Shuttle__c> forUpdate = new List<Payment_Shuttle__c>();
        Map<String, Payment_Shuttle__c> failed = new Map<String, Payment_Shuttle__c>();
        ComboRuleProvider provider = ComboRuleProvider.getInstance();
        
		for( Payment_Shuttle__c someShuttle : scope ) {
            
            String someCompanyKey = someShuttle.Company_ID__c;
            // Intercompany handling.
            if(someShuttle.Intercompany_ID__c == 'ASHRC') {
                someCompanyKey = 'ASHRC';
            }
            if(someShuttle.Intercompany_ID__c == 'ASH') {
                someCompanyKey = 'ASH';
            }            
               
            boolean result = provider.validate(someCompanyKey, someShuttle.Account_Code__c, someShuttle.Department__c, 
                              someShuttle.Program__c, someShuttle.Project__c, someShuttle.Other__c);
            if(result == false) {
                someShuttle.Failed__c = true;
                someShuttle.Reason__c = 'Invalid account code.';
                if(someShuttle.Invoice_Number__c != null) { 
                	failed.put(someShuttle.Vendor_ID__c + '-' + someShuttle.Invoice_Number__c, someShuttle);
                }
            }
			forUpdate.add(someShuttle);            
        }
        
        // Now we loop through all failed shuttles, and also 'fail' all related shuttles.
        // This prevents half an invoice from being marked as invalid.
        for( Payment_Shuttle__c someShuttle : forUpdate ) {
            if (failed.containsKey( someShuttle.Vendor_ID__c + '-' + someShuttle.Invoice_Number__c )) {
                if(someShuttle.Failed__c == false) {
                    someShuttle.Failed__c = true; 
                    someShuttle.Reason__c = 'Failed as accomplice.';  
                }
            }
        }      
        
        update forUpdate;      
    }
    
    global void finish(Database.BatchableContext bc) {
        Concur_Batch__c newBatch = [SELECT Id FROM Concur_Batch__c WHERE Id = :batchId];
        newBatch.Validated__c = true;
        update newBatch;  
    }
    
}