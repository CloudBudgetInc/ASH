global class ReconciliationBulkMatcherBatch implements Database.Batchable<sObject> {
    
    String company = '';
    String account = '';
    String bypassOrderMatching = '';
    public ReconciliationBulkMatcherBatch(String company, String account, String bypassOrderMatching) {
		this.company = company;
        this.account = account;
        this.bypassOrderMatching = bypassOrderMatching;
    }        
    
  global Database.QueryLocator start(Database.BatchableContext BC) {
        
      String matchStatus = 'Unmatched';
        String query = 'SELECT Id, CreditDebit__c, Amount__c, Transaction_Amount__c, Customer_Id__c, ' + 
            'Order_Number__c, Internal_Account__c, Effective_Date__c FROM Personify_Transaction__c ' + 
            'WHERE Match_Status__c = :matchStatus ' + 
            'AND Hidden__c = false ' + 
            'AND Account__c = :account ' + 
            'AND Company__c = :company ' + 
            'ORDER BY Customer_Id__c, Order_Number__c';
    return Database.getQueryLocator(query);
    }
    
  global void execute(Database.BatchableContext BC, List<Personify_Transaction__c> personifyTransactions) {

        Boolean bypassOrderMatch = Boolean.valueOf(bypassOrderMatching);
        
    List<Personify_Transaction__c> ptxForUpdate = new List<Personify_Transaction__c>();
        
        // All transactions grouped by order num or customer number, depending on setting/config.
        Map<String, List<Personify_Transaction__c>> groupedTxs = new Map<String, List<Personify_Transaction__c>>();
        
        // Since we're looping thru em all, let's add the transaction to a List grouped either by order number or 
        // by customer number. Generally, the system should match on order number but we have a setting that allows
        // for direct matching on customer number if desired. Sometimes this is needed as the order required to 
        // complete a match is unique.
        for( Personify_Transaction__c tx : personifyTransactions ) {
            if( bypassOrderMatch == true ){ 
                List<Personify_Transaction__c> someList = groupedTxs.get(tx.Customer_Id__c);
                if(someList == null) {
                    someList = new List<Personify_Transaction__c>();
                }
                someList.add(tx);
                groupedTxs.put(tx.Customer_Id__c, someList);        
            
            } else {
                List<Personify_Transaction__c> someList = groupedTxs.get(tx.Order_Number__c);
                if(someList == null) {
                    someList = new List<Personify_Transaction__c>();
                }
                someList.add(tx);
                groupedTxs.put(tx.Order_Number__c, someList);                
            }
        }
            
        // Let's loop our collection of grouped transactions. Add 'em up - if they total 0.00, they match.
        Set<String> keys = new Set<String>();
        keys = groupedTxs.keySet();
        for( String key : keys ) {
            List<Personify_Transaction__c> transactions = groupedTxs.get(key);
            
            Decimal total = 0.00;
            String customerId;
            for( Personify_Transaction__c someTransaction : transactions ) {
                total += someTransaction.Amount__c;
                customerId = someTransaction.Customer_Id__c;
            }
            
            if( total == 0.00 ) {
                Personify_Match__c match = new Personify_Match__c();
                if(bypassOrderMatch) { match.Customer_ID__c = key; }
                if(!bypassOrderMatch) { 
                    match.Customer_ID__c = customerId;
                    match.Order_Number__c = key; 
                }
                insert match;
              for( Personify_Transaction__c someTransaction : transactions ) {
                  someTransaction.Personify_Match__c = match.Id;
                     someTransaction.Match_Status__c = 'Matched';
                    someTransaction.Match_Comments__c = 'Bulk matched on ' + System.today();                    
                    ptxForUpdate.add(someTransaction);
              }
            }
        }
        update ptxForUpdate;
    }
    
    global void finish(Database.BatchableContext bc){ }   
}