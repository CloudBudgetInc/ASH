@IsTest
public with sharing class CustomLoginControllerTest {
    @isTest
    public static void testCustomLoginController () {
        String username = 'test';
        String password = 'test';
        String startUrl = '/';
        System.assert(CustomLoginController.doLogin(username, password, startUrl) == null);

        User testUser = [SELECT Id, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
        System.assertEquals(testUser, CustomLoginController.fetchUser());

        System.assert(CustomLoginController.isLoggedIn());
    }

    @isTest(SeeAllData=true)
	public static void testCustomLoginControllerNoContact() {
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
			System.assert(CustomLoginController.fetchContact() == null);

			test.stopTest();
		}
    }
    
    @isTest(SeeAllData=true)
	public static void testCustomLoginControllerContact() {
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
			System.assert(CustomLoginController.fetchContact().Id == contactUser.ContactId);
			test.stopTest();
		}
	}
}