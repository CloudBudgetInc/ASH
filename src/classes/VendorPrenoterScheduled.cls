global class VendorPrenoterScheduled implements Schedulable, Database.Batchable<sObject> {
    
   global Database.QueryLocator start(Database.BatchableContext BC) { 
       
       	DateTime now = System.now();
        String prenoteStatus = 'Pending';
        String query = 'SELECT Id FROM Account WHERE Date_of_Prenote_Approval__c < :now AND Prenote_Status__c = :prenoteStatus';
		return Database.getQueryLocator(query);
    }       
    
   	global void execute(Database.BatchableContext BC, List<Account> someVendors) { 

       List<Account> accountsForUpdate = new List<Account>();
       for( Account someVendor : someVendors ) {
           System.debug(someVendor.Id);
           someVendor.Prenote_Status__c = 'Approved';
           someVendor.c2g__CODAPaymentMethod__c = 'ACH';
           accountsForUpdate.add(someVendor);
       }
       update accountsForUpdate;
   }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new VendorPrenoterScheduled());
    }    
    
    global void finish(Database.BatchableContext bc) { }    
}