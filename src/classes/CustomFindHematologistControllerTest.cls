@isTest
	public with sharing class CustomFindHematologistControllerTest {
		@isTest
		public static void testCustomFindHematologistController() {
			System.assert(CustomFindHematologistController.getContact() == null);
			System.assert(CustomFindHematologistController.getAddress() == null);
			System.assert(CustomFindHematologistController.updateOptIn(false) == null);

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

			Address__c addr = new Address__c(
				Person__c = testContact.Id,
				Find_a_Hematologist__c = true
			);
			insert addr;

			System.runAs(contactUser) {
				test.startTest();
				System.assert(CustomFindHematologistController.getContact().Id == contactUser.ContactId);
				System.assert(CustomFindHematologistController.checkMemberStatus() == contactUser.ASH_Member__c);
				// System.assert(CustomFindHematologistController.getAddress() != null);
				System.assert(CustomFindHematologistController.updateOptIn(false).Id == contactUser.ContactId);
				test.stopTest();
			}
		}
	}