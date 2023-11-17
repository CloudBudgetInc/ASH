@isTest(SeeAllData=true)
public class PersonifyTriggerTest {

    static testMethod void testPersonifyTriggerTest() { 
        
        Personify_Transaction__c tx1 = new Personify_Transaction__c(Order_Number__c = '99999999', Customer_Id__c = '88888888', 
            CreditDebit__c = 'D', Match_Status__c = 'Unmatched', Transaction_Amount__c = '100.00');
        Personify_Transaction__c tx2 = new Personify_Transaction__c(Order_Number__c = '99999999', Customer_Id__c = '88888888', 
            CreditDebit__c = 'C', Match_Status__c = 'Unmatched', Transaction_Amount__c = '50.00');
        Personify_Transaction__c tx3 = new Personify_Transaction__c(Order_Number__c = '99999999', Customer_Id__c = '88888888', 
            CreditDebit__c = 'C', Match_Status__c = 'Unmatched', Transaction_Amount__c = '50.00');

        List<Personify_Transaction__c> txs = new List<Personify_Transaction__c>();
        txs.add(tx1);
        txs.add(tx2);
        txs.add(tx3);        
        insert txs;
        tx1.Supermatch__c = true;
		update tx1;        
        List<Personify_Match__c> result = [SELECT Id FROM Personify_Match__c WHERE Customer_Id__c = '88888888'];
        System.assert(result.size() > 0);
    }
}