@IsTest
public with sharing class VeevaAddressTriggerTest {
	@IsTest
	public static void testVeevaAddressTriggerTest() {
		Account acct = new Account(
			Name = 'Test CTU Org'
		);
		insert acct;

		Clinical_Trial_Unit__c ctu = new Clinical_Trial_Unit__c(
			Name = 'Test CTU Org',
			Primary_Site__c = acct.Id
		);
		insert ctu;

		Address__c addr = new Address__c(
			CTN__c = ctu.Id
		);
		insert addr;

		addr.Street__c = '123 Main St.';
		update addr;
		
		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assertEquals(3, Limits.getFutureCalls());
	}
}