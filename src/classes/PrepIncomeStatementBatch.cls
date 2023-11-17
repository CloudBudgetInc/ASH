global class PrepIncomeStatementBatch implements Database.Batchable<sObject> {
    
    String company = 'ASH';
    String period;
    
    public PrepIncomeStatementBatch(String company, String period) {
        this.company = company;
        this.period = period;
    }
   
  	global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String type = 'Actual';
        List<String> categories = new List<String>();
        categories.add('Expense');
        categories.add('Income');
        String query = 'SELECT Id, c2g__GeneralLedgerAccount__c, c2g__Dimension1__c, c2g__Dimension2__c, ' + 
            'c2g__Dimension3__c, c2g__Dimension4__c, c2g__IntersectDefinition__c, c2g__Period__c, c2g__HomeValue__c ' + 
            'FROM c2g__ReportingBalance__c ' + 
            'WHERE PerPost__c = :period AND ' +            
            'c2g__OwnerCompany__r.Key__c = :company AND ' +
            'c2g__Type__c = :type AND ' + 
            'c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN :categories';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c > results) {
        
        // Clear out any existing reporting balances of type 'Current'.
        List<c2g__ReportingBalance__c> forDeletion = [SELECT Id FROM c2g__ReportingBalance__c  
                                                     WHERE c2g__OwnerCompany__r.Key__c = :company AND c2g__Type__c = 'Current'];
        delete forDeletion;
        
        List<c2g__ReportingBalance__c> forInsertion = new List<c2g__ReportingBalance__c>();
        
        for( c2g__ReportingBalance__c someBalance : results ) {
            c2g__ReportingBalance__c newBalance = new c2g__ReportingBalance__c(
                c2g__GeneralLedgerAccount__c=someBalance.c2g__GeneralLedgerAccount__c, 
                c2g__Dimension1__c = someBalance.c2g__Dimension1__c,
                c2g__Dimension2__c = someBalance.c2g__Dimension2__c, 
                c2g__Dimension3__c = someBalance.c2g__Dimension3__c, 
                c2g__Dimension4__c = somebalance.c2g__Dimension4__c,
                c2g__HomeValue__c = someBalance.c2g__HomeValue__c, 
                c2g__Period__c = someBalance.c2g__Period__c,
                c2g__IntersectDefinition__c = someBalance.c2g__IntersectDefinition__c,
                c2g__Type__c = 'Current');
            forInsertion.add(newBalance);
        }
        
        insert forInsertion;
    }
    
    global void finish(Database.BatchableContext bc) { 
        
        // Check batch status.
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email, ExtendedStatus
            from AsyncApexJob where Id = :bc.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'rtolocka.itconsultant@hematology.org', 'jkingue@hematology.org'};
        mail.setToAddresses(toAddresses);        
        
	  	if(a.NumberOfErrors == 0) {        
            mail.setSubject('Prep Income Statement Batch - Complete');
            mail.setPlainTextBody('Prep Income Statement Batch - Complete for ' + company + ', ' + period + '.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        else {
            mail.setSubject('Prep Income Statement Batch - Failed');
            mail.setPlainTextBody('Prep Income Statement Batch - Failed for ' + company + ', ' + period + '. Please check your Company selection.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
        }
    }
}