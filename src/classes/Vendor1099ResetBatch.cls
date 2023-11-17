global class Vendor1099ResetBatch implements Database.Batchable<sObject> {

    String vendorId;

    /** 
     * This batch resets the 1099 processed flag, allowing us to run another batch.
     */
    public Vendor1099ResetBatch() { }      
    
    public Vendor1099ResetBatch(String vendorId) {
        this.vendorId = vendorId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        
        String query;
        if(vendorId != null) {
            query = 'SELECT Id, Vendor_Id__c, X1099_Processed__c FROM Account WHERE Vendor_Id__c = :vendorId';  
        }
        else {
            query = 'SELECT Id, Vendor_Id__c, X1099_Processed__c FROM Account WHERE X1099_Processed__c = true';  
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> results) {
        
        List<Account> knockdowns = new List<Account>();

        for( Account someAccount : results ) {
			someAccount.X1099_Processed__c = false;
            knockdowns.add(someAccount); 
        }
        update knockdowns;       
    }
       
    global void finish(Database.BatchableContext bc) { }
}