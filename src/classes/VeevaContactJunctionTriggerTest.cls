@IsTest
public with sharing class VeevaContactJunctionTriggerTest {
	@IsTest
	public static void testVeevaContactJunctionTrigger() {
		Contact c = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test@gmail.com'
		);
		insert c;

		Contact_Junction__c cj = new Contact_Junction__c(Contact__c = c.Id);
		insert cj;
		
		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assert(Limits.getFutureCalls() > 0);
	}
}