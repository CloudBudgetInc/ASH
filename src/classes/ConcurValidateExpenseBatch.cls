global class ConcurValidateExpenseBatch implements Database.Batchable<sObject> {

    String batchId;
    
    public ConcurValidateExpenseBatch(String batchId) {
        this.batchId = batchId; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String type = 'Expense';
        String query = 'SELECT Account_Code__c, Department__c, Program__c, Project__c, Invoice_Number__c, ' + 
            'Other__c, Company_ID__c, Intercompany_ID__c, Vendor_ID__c FROM Payment_Shuttle__c ' + 
            'WHERE Concur_Batch__c = :batchId and Type__c = :type';
		return Database.getQueryLocator(query);
	}
		    
    global void execute(Database.BatchableContext BC, List<Payment_Shuttle__c> scope) {

		List<Payment_Shuttle__c> forUpdate = new List<Payment_Shuttle__c>();
        Map<String, Payment_Shuttle__c> failed = new Map<String, Payment_Shuttle__c>();
        ComboRuleProvider provider = ComboRuleProvider.getInstance();
        
        System.debug('Beginning validation process.'); 
		for( Payment_Shuttle__c someShuttle : scope ) {
            
            String someCompanyKey = someShuttle.Company_ID__c;
            if(someShuttle.Intercompany_ID__c == 'ASHRC') {
                someCompanyKey = 'ASHRC';
            }
               
            boolean result = provider.validate(someCompanyKey, someShuttle.Account_Code__c, 
                              someShuttle.Department__c, someShuttle.Program__c, 
                              someShuttle.Project__c, someShuttle.Other__c);
            if(result == false) {
                someShuttle.Failed__c = true;
                someShuttle.Reason__c = 'Invalid account code.';
                forUpdate.add(someShuttle);
                if(someShuttle.Invoice_Number__c != null) { 
                	failed.put(someShuttle.Vendor_ID__c + '-' + someShuttle.Invoice_Number__c, someShuttle);
                }
            } else if (failed.containsKey( someShuttle.Vendor_ID__c + '-' + someShuttle.Invoice_Number__c )) {
                someShuttle.Failed__c = true;
                someShuttle.Reason__c = 'Failed as accomplice.';
                forUpdate.add(someShuttle);
            }
        }
        update forUpdate;
    }
    
    global void finish(Database.BatchableContext bc) { }
}