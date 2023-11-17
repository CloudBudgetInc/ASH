@isTest(SeeAllData=true)
public with sharing class CustomASHRCSubscriptionControllerTest {
	@isTest(SeeAllData=true)
	public static void testCustomASHRCSubscriptionController() {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ASH RC Member Login' LIMIT 1];

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
			ContactId = testContact.Id
		);

		System.runAs(contactUser) {
			test.startTest();
			System.assert(CustomASHRCSubscriptionController.getContact().Id == contactUser.ContactId);
			test.stopTest();
		}
	}

	@isTest(SeeAllData=true)
	public static void testCustomASHRCSubscriptionControllerNoContact() {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

		User testUser = new User(
			LastName = 'test user 1', 
			Username = 'test.user.1@example.com', 
			Email = 'test.1@example.com', 
			Alias = 'testu1', 
			TimeZoneSidKey = 'GMT', 
			LocaleSidKey = 'en_GB', 
			EmailEncodingKey = 'ISO-8859-1', 
			ProfileId = testProfile.Id, 
			LanguageLocaleKey = 'en_US'
		);

		System.runAs(testUser) {
			test.startTest();
			System.assert(CustomASHRCSubscriptionController.getContact() == null);

			test.stopTest();
		}

		System.assert(CustomASHRCSubscriptionController.subscribeAll(false) == null);
	}
}