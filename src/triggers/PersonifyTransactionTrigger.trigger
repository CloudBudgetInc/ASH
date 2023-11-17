trigger PersonifyTransactionTrigger on Personify_Transaction__c (after update) {
 
    if (Trigger.isAfter ) {
		if( trigger.isUpdate ) 
		{
        	for( Personify_Transaction__c tx : trigger.new )
    		{       
     			if(Trigger.oldMap.get(tx.Id).Supermatch__c != tx.Supermatch__c && 
					tx.Supermatch__c == true) {
                        if( tx.CreditDebit__c == 'C') { 
                        	tx.addError('Supermatch can only be run on Debits.');
                        }
                        else {
                            // Look for related transactions, i.e. those that share a customer ID and order number.
                            String customerId = tx.Customer_Id__c;
                            String orderNumber = tx.Order_Number__c;
                            String internalAccount = tx.Internal_Account__c;
                            List<Personify_Transaction__c> txs = [SELECT Amount__c, Match_Status__c, CreditDebit__c 
                                FROM Personify_Transaction__c WHERE Customer_Id__c = :customerId AND 
                                Internal_Account__c = :internalAccount AND 
                                Order_Number__c = :orderNumber AND Match_Status__c = 'Unmatched'];
                            Decimal total = 0.00;
                            for(Personify_Transaction__c someTx : txs) {
                                total += someTx.Amount__c;
                            }
                            // If they add up to zero, we can match them off by creating a PersonifyMatch record and setting status.
                            if( total == 0) {
                                Personify_Match__c newMatch = new Personify_Match__c(Customer_Id__c = customerId, Order_Number__c = orderNumber);
                                insert newMatch;
                                List<Personify_Transaction__c> forUpdate = new List<Personify_Transaction__c>();
                                for(Personify_Transaction__c someTx : txs) {
                                    someTx.Personify_Match__c = newMatch.Id;
                                    someTx.Match_Status__c = 'Matched';
                                    someTx.Match_Comments__c = 'Matched via supermatch.';
                                    forUpdate.add(someTx);
                                }                        
                                update forUpdate;
                            }
                            else {
                                tx.addError('No related transactions were found, or transactions do not add up to zero.');
                            } 
                        }
 
                    }
            	}
          }
     }
}