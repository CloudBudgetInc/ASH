@isTest(SeeAllData=true)
public with sharing class CustomCommitteeMemberControllerTest {
  @isTest(SeeAllData=true)
	public static void testCustomCommitteeMemberController() {
		 System.assert(CustomCommitteeMemberController.getCommitteeMembers('0013u0000175AbVAAU').size() > 0);
		System.assert(CustomCommitteeMemberController.getEmailTemplates().size() > 0);
		System.assert(CustomCommitteeMemberController.getOrgEmailAddress().size() > 0);

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

		List<Id> contactIds = new List<Id>();
		contactIds.add(testContact.Id);

		List<EmailTemplate> templates = [
			SELECT Id,HtmlValue,Subject,Name FROM EmailTemplate
		];

		List<OrgWideEmailAddress> addresses = [
			SELECT Address,DisplayName,Id FROM OrgWideEmailAddress
		];

		// System.runAs(contactUser) {
			test.startTest();
			System.assert(CustomCommitteeMemberController.sendEmail(contactIds,'body','subject',templates.get(0).Id,addresses.get(0).Id) == 'The email was sent successfully.');
        	System.assert(CustomCommitteeMemberController.getAssistant('0033u000015WLhPAAW').size()>0);
        	System.assert(CustomCommitteeMemberController.verifyHasEditPermissions() == false);
        	test.stopTest();
		// }
	}
}