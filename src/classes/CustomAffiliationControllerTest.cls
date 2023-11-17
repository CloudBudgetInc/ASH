@isTest
public with sharing class CustomAffiliationControllerTest {
  @isTest
	public static void testCustomAffiliationController () {
		System.assert(CustomAffiliationController.getAffiliations() == null);
		System.assert(CustomAffiliationController.getAffiliatedStaff() == null);
		System.assert(CustomAffiliationController.getContactId() == null);

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
			System.assert(CustomAffiliationController.getContactId() == contactUser.ContactId);
			System.assert(CustomAffiliationController.getCurrentUserId() == contactUser.Id);
			System.assert(CustomAffiliationController.getAffiliations() == null);
			System.assert(CustomAffiliationController.getAffiliatedStaff() == null);
			test.stopTest();
		}
	}

	@isTest
	public static void testCustomAffiliationControllerPending() {
		PenRec__c pending = new PenRec__c(
			First_Name__c = 'test'
		);
		insert pending;

		System.assert(CustomAffiliationController.getPendingOrg(pending.Id).Id == pending.Id);
	}

	@isTest
	public static void testCustomAffiliationControllerDelete() {
		Contact testContact = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test.user.1@example.com'
		);
		insert testContact;

		Affiliate__c aff = new Affiliate__c(
			Contact__c = testContact.Id
		);
		insert aff;

		System.assert(CustomAffiliationController.deleteAffiliationById(aff.Id) == aff.Id);
	}
}