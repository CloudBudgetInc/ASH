@isTest
public with sharing class CustomAddressControllerTest {
  @isTest
	public static void testCustomAddressNull() {
		System.assert(CustomAddressController.getAddresses() == null);
		System.assert(CustomAddressController.getContactId() == null);
		System.assert(CustomAddressController.getAccountId() == null);

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
			System.assert(CustomAddressController.getAddresses() == null);
			System.assert(CustomAddressController.getContactId() == contactUser.ContactId);
			System.assert(CustomAddressController.checkMemberStatus() == contactUser.ASH_Member__c);
			test.stopTest();
		}
	}

	public static void testCustomAddressController() {
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

		Address__c addr = new Address__c(
			Person__c = testContact.Id
		);
		insert addr;

		System.runAs(contactUser) {
			test.startTest();
			System.assert(CustomAddressController.getAddresses().size() > 0);
			System.assert(CustomAddressController.getAccountId() == null);
			System.assert(CustomAddressController.removeAddressById(addr.Id) == addr.Id);
			test.stopTest();
		}
	}
}