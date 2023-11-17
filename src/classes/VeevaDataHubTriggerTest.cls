@IsTest
public with sharing class VeevaDataHubTriggerTest {
	@IsTest
	public static void testVeevaDataHubTrigger() {
		Account acct = new Account(
			Name = 'DH Test Org'
		);
		insert acct;

		Data_Hub_Contributor__c dh = new Data_Hub_Contributor__c(
			Name = 'DH Test Org',
			Institution__c = acct.Id
		);
		insert dh;

		dh.Name = 'DH Test Org';
		update dh;
		
		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assertEquals(2, Limits.getFutureCalls());
	}
}