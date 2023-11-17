@IsTest(SeeAllData=true)
public inherited sharing class CustomUserProfilePhotoControllerTest {
	@IsTest(SeeAllData=true)
	public static void testCustomUserProfilePhotoController() {
		System.assertEquals(null, CustomUserProfilePhotoController.getContact('0053u0000041hatAAA'));
		System.assertEquals(null, CustomUserProfilePhotoController.getUserByContactId('0053u0000041hatAAA'));

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
			System.assertEquals(testContact.Id, CustomUserProfilePhotoController.getContact(testContact.Id).Id);
			System.assertEquals(contactUser.Id, CustomUserProfilePhotoController.getUserByContactId(testContact.Id).Id);
			System.assertEquals(true, CustomUserProfilePhotoController.isCurrentUser(contactUser.Id));
			System.assertEquals(true, CustomUserProfilePhotoController.deleteProfileImage());
			System.assert(CustomUserProfilePhotoController.getProfileImage(contactUser.Id).largePhotoUrl != null);
			test.stopTest();
		}
	}
}