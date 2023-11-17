@IsTest
public with sharing class VeevaContactTriggerTest {
	@IsTest
	public static void testVeevaContactTrigger() {
		Contact c = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test@gmail.com'
		);
		insert c;

		// c.Veeva_ID__c = 'VB0012320313';
		// update c;
		
		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assert(Limits.getFutureCalls() == 0);
	}
}