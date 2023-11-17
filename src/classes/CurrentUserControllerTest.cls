@isTest
public with sharing class CurrentUserControllerTest {
	@isTest
	public static void testCurrentUserController() {
		User testUser = [SELECT Id, Name, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
		
		User user = CurrentUserController.updateLLSAuth();

		System.assertEquals(user.LLS_Authorized__c, true);

		System.assertEquals(testUser.FirstName, CurrentUserController.getCurrentUser().FirstName);
		System.assertEquals(testUser.LastName, CurrentUserController.getCurrentUser().LastName);
		System.assertEquals(testUser.Id, CurrentUserController.getCurrentUser().Id);

		System.assertEquals(testUser.Id, CurrentUserController.getUserById(testUser.Id).Id);

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
			// System.assert(CurrentUserController.getContact().Id == contactUser.ContactId);
			System.assert(CurrentUserController.checkMemberStatus() == contactUser.ASH_Member__c);
			System.assert(CurrentUserController.updateMemberDirectory(true).Id == contactUser.ContactId);
			test.stopTest();
		}
	}
}