global class Vendor1099FlushBatch implements Database.Batchable<sObject> {

    String taxYear = '';
    
    /**
     * This batch job deletes all 1099 records for a particular year, allowing us to 
     * run another batch without duplication of data.
     */
    public Vendor1099FlushBatch(String taxYear) {
        this.taxYear = taxYear;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 

        String query = 'SELECT Id FROM X1099_Year__c WHERE Tax_Year__c = :taxYear'; 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<X1099_Year__c> results) {
        delete results;
    }
       
    global void finish(Database.BatchableContext bc) { }
}