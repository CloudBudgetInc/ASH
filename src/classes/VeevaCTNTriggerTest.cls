@IsTest
public with sharing class VeevaCTNTriggerTest {
	@IsTest
	public static void testVeevaCTNTrigger() {
		Account acct = new Account(
			Name = 'Test CTU Org'
		);
		insert acct;

		Clinical_Trial_Unit__c c = new Clinical_Trial_Unit__c(
			Name = 'Test CTU Org',
			Primary_Site__c = acct.Id
		);
		insert c;

		c.Name = 'Test CTU Org';
		update c;
		
		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assertEquals(2, Limits.getFutureCalls());
	}
}