@IsTest(SeeAllData=true)
public with sharing class CustomUserProfileControllerTest {
	@IsTest(SeeAllData=true)
	public static void testCustomUserProfileController() {
		User[] users = [SELECT Id, FirstName, LastName, SenderEmail, ContactId FROM User LIMIT 1];

		Contact_Junction__c[] contacts = [SELECT Id, Clinical_Trial_Unit__r.Name, Clinical_Trial_Unit__r.Consortium__r.Name, Clinical_Trial_Unit__r.Primary_Site__r.Name, 
			Clinical_Trial_Unit__r.Primary_Site__r.BillingAddress, Clinical_Trial_Unit__c, Contact__c, Contact__r.Name, Contact__r.Title, 
			Contact__r.Email, Contact__r.Phone, Contact_Type__c 
			FROM Contact_Junction__c WHERE Clinical_Trial_Unit__c != '' LIMIT 1];

		User currentUser = [SELECT Id, FullPhotoURL FROM User WHERE Id =: UserInfo.getUserId()];

		if (users.size() > 0) {
			User u = users[0];
			User user = CustomUserProfileController.getUserById(u.Id);
			System.assertEquals(u.Id, user.Id);
			System.assertEquals(u.FirstName, user.FirstName);
		}

		if (contacts.size() > 0) {
			Contact_Junction__c c = contacts[0];
			Contact_Junction__c contact = CustomUserProfileController.getContactJunctionById(c.Id);
			System.assertEquals(c.Id, contact.Id);
			System.assertEquals(c.Contact__r.Name, contact.Contact__r.Name);
			System.assertEquals(c.Contact__r.Email, contact.Contact__r.Email);
			System.assertEquals(c.Contact__r.Title, contact.Contact__r.Title);
		
			Contact_Junction__c ca = CustomUserProfileController.getAddressByContactJunction(c.Id, c.Clinical_Trial_Unit__c);
			System.assert(ca == null);
		}

		System.assertEquals(currentUser.Id, CustomUserProfileController.getCurrentUser().Id);
		System.assertEquals(currentUser.FullPhotoURL, CustomUserProfileController.getProfileImage(currentUser.Id).largePhotoUrl);

		System.assert(CustomUserProfileController.getContactJunctionByUser() == null);

		// ConnectApi.Photo photo = CustomUserProfileController.uploadProfileImage('', 'png', 'test');
		// System.assert(photo != null);
	}

	@isTest
	public static void testCustomUserProfileLoggedInController () {
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
		insert contactUser;

		testContact.ASHRC_User__c = contactUser.Id;
		update testContact;

		Contact_Junction__c cj = new Contact_Junction__c(Contact__c = testContact.Id);
		insert cj;

		System.runAs(contactUser) {
			test.startTest();
			Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
			System.assertEquals(contactUser.Id, CustomUserProfileController.getCurrentUser().Id);
			System.assertEquals(contactUser.Id, CustomUserProfileController.getUserById(contactUser.Id).Id);
			System.assertEquals(CustomUserProfileController.getContactJunctionByUser().Id, cj.Id);
			test.stopTest();
		}
	}
}