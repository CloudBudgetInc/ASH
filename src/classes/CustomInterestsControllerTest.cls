@isTest
public with sharing class CustomInterestsControllerTest {
	@isTest
	public static void testInterestsController () {
		System.assert(CustomInterestsController.getInterests() == null);

		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User (okta)' LIMIT 1];

		Contact testContact = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test.user.1@example.com'
		);
		insert testContact;

		User contactUser = new User(
			LastName = 'test user 1', 
			Username = 'test.user.1@example.com', 
			Email = 'test.1@example.com', 
			Alias = 'testu1', 
			TimeZoneSidKey = 'GMT', 
			LocaleSidKey = 'en_GB', 
			EmailEncodingKey = 'ISO-8859-1', 
			ProfileId = testProfile.Id, 
			LanguageLocaleKey = 'en_US',
			ContactId = testContact.Id,
			ASH_Member__c = false
		);

		System.runAs(contactUser) {
			test.startTest();
			System.assert(CustomInterestsController.getInterests().Id == contactUser.ContactId);
			test.stopTest();
		}
	}
}