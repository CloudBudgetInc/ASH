global class ReconciliationMatcherBatch implements Database.Batchable<sObject> {
    
    String account = '';
    String dateMatchingActive = '';
    
    public ReconciliationMatcherBatch(String account, String dateMatchingActive) {
        this.account = account;
        this.dateMatchingActive = dateMatchingActive;
    }     
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

	    String matchStatus = 'Unmatched';
        String query = 'SELECT Id, CreditDebit__c, Amount__c, Transaction_Amount__c, Customer_Id__c, ' + 
            'Order_Number__c, Internal_Account__c, Effective_Date__c FROM Personify_Transaction__c ' + 
            'WHERE Match_Status__c = :matchStatus ' + 
            'AND Hidden__c = false ' + 
            'AND Account__c = :account ' + 
            'ORDER BY Customer_Id__c, Order_Number__c';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<Personify_Transaction__c> personifyTransactions) {

        Boolean dateMatchActive = Boolean.valueOf(dateMatchingActive);
        
		List<Personify_Transaction__c> ptxForUpdate = new List<Personify_Transaction__c>();
        List<Personify_Transaction__c> morePersonifyTransactions = personifyTransactions.clone();
        Map<Id,String> matched = new Map<Id,String>();
        
        for( Personify_Transaction__c tx : personifyTransactions ) {

            // Loop through a cloned collection, looking for 'mirror image transactions.'
            // Match on amount, cust id, order number.
            for( Personify_Transaction__c tx2 : morePersonifyTransactions ) {
                if(matched.containsKey(tx2.Id)) { continue; } // prevent matching the same tx twice.                
                	if(tx.Internal_Account__c.substring(0,4) == tx2.Internal_Account__c.substring(0,4)) {
               	    	if((tx.Amount__c + tx2.Amount__c) == 0.00) {
              	          if(tx.Customer_Id__c == tx2.Customer_Id__c &&  tx.Order_Number__c == tx2.Order_Number__c &&  tx.CreditDebit__c != tx2.CreditDebit__c ) {
                                 if( dateMatchActive == true ) {
                                 	if( tx.Effective_Date__c == tx2.Effective_Date__c ) {
                               			tx.Match_Status__c = 'Matched';
                               			tx.Matched_Transaction__c = tx2.Id;                                        
                               			tx.Match_Comments__c = 'Matched on ' + tx2.Customer_Id__c + ', ' + tx2.Order_Number__c + ', ' + tx2.CreditDebit__c;
                                        matched.put(tx2.Id, 'Matched');
                               			ptxForUpdate.add(tx);
                               			break;
                                    }
                                 } else {
                               			tx.Match_Status__c = 'Matched';
                               			tx.Matched_Transaction__c = tx2.Id;                                     
                               			tx.Match_Comments__c = 'Matched on ' + tx2.Customer_Id__c + ', ' + tx2.Order_Number__c + ', ' + tx2.CreditDebit__c;
                                        matched.put(tx2.Id, 'Matched');
                               			ptxForUpdate.add(tx);
                               			break;                                     
                                 }
                           }
                    	}
                	}
            } // end for loop. At this point we've matched all the 'duos'.
        }
        update ptxForUpdate;
    }
    
    global void finish(Database.BatchableContext bc){ }    
}