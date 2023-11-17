global class PersonnelBudgetFlushStagers implements Database.Batchable<sObject> {
    
    String batchId;
    
    public PersonnelBudgetFlushStagers(String batchId) {
        this.batchId = batchId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) { 
        
        String query = 'SELECT Account_Subaccount__c, Company__c, Period__c, Amount__c ' + 
        	'FROM Personnel_Budget_Stager__c WHERE Personnel_Budget_Batch__c = :batchId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Personnel_Budget_Stager__c> stagers) {
        delete stagers;
    }
    
    global void finish(Database.BatchableContext bc) { }

}