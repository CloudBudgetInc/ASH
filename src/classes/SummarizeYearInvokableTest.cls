@isTest(SeeAllData=true)
public class SummarizeYearInvokableTest {
    
	public static testmethod void testInvokable() {

		Test.startTest();
	    List<String> params = new List<String>();
     	params.add('ASH');
        params.add('202312');
        params.add('202400');
        params.add('Actual');
        List<List<String>> outerParams = new List<List<String>>();
        outerParams.add(params);
     	SummarizeYearInvokable.invokeSummarizeYear(outerParams);
     	Test.stopTest();
        
        List<c2g__codaJournal__c> someJournals = [SELECT Id, c2g__Total__c, c2g__Debits__c, c2g__Credits__c FROM c2g__codaJournal__c 
        	WHERE CreatedDate = TODAY AND c2g__JournalStatus__c = 'In Progress' AND 
			c2g__JournalDescription__c LIKE 'Rollover Balances%'];
        System.assert(someJournals.size() > 0);
 	}   
}