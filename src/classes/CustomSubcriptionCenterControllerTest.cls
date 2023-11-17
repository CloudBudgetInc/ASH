@IsTest
public with sharing class CustomSubcriptionCenterControllerTest {
	@IsTest
	public static void testCustomSubcriptionCenterController() {
		System.assert(CustomSubcriptionCenterController.getSubscriptions() == null);
		System.assert(CustomSubcriptionCenterController.subscribeAll(false) == null);

		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User (okta)' LIMIT 1];

		Contact testContact = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test.user.1@example.com'
		);
		insert testContact;

		System.assert(CustomSubcriptionCenterController.updateSubscriptions(testContact) == null);

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
			System.assert(CustomSubcriptionCenterController.getUser().Id == contactUser.Id);
			System.assert(CustomSubcriptionCenterController.getSubscriptions().Id == contactUser.ContactId);
			System.assert(CustomSubcriptionCenterController.subscribeAll(false).Id == contactUser.ContactId);
			System.assert(CustomSubcriptionCenterController.updateSubscriptions(testContact).Id == contactUser.ContactId);
			test.stopTest();
		}
	}
}