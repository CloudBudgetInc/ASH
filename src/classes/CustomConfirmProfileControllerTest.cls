@isTest
public with sharing class CustomConfirmProfileControllerTest {
  @isTest
	public static void testCustomConfirmProfileController () {
		System.assert(CustomConfirmProfileController.getContact() == null);
		System.assert(CustomConfirmProfileController.confirmProfile() == null);

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
			ASH_Member__c = true
		);

		System.runAs(contactUser) {
			test.startTest();
			// System.assert(CustomConfirmProfileController.getContact().Id == contactUser.ContactId);
			System.assert(CustomConfirmProfileController.confirmProfile() != null);
			test.stopTest();
		}
	}
}