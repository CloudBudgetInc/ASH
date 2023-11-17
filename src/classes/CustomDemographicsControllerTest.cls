@isTest
public with sharing class CustomDemographicsControllerTest {
  @TestSetup
  public static void makeData () {
		User thisUser = [SELECT Id, contactId FROM User WHERE Id = :UserInfo.getUserId()];
        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'ASH' LIMIT 1];
        thisUser.UserRoleId = userRole.Id;
        update thisUser;

        System.runAs (thisUser) {
            Id profileId = [Select Id From Profile Where Name ='Customer Community Login User (okta)'].Id;

            Account portalAccount = new Account( name = 'Test Name');
            insert portalAccount;
    
            Contact portalContact = new contact(    FirstName = 'Test',
                                                    LastName = 'Contact',
                                                    Email = 'test@gmail.com',
                                                    AccountId = portalAccount.id,
													Gender_Self_Describe__c = 'Male',
												 	Pronouns__c = 'He, Him and His');
            insert portalContact;
    
            User portalUser = new User( FirstName = 'firstName',
                                        LastName = 'lastName',
                                        email = 'testUser1@sfdc1.org',
                                        Username = 'test1@sfdc1.org',
                                        EmailEncodingKey = 'ISO-8859-1',
                                        TimeZoneSidKey = 'America/Los_Angeles',
                                        LocaleSidKey = 'en_US',
                                        LanguageLocaleKey = 'en_US',
                                        Alias = 'portalU1',
                                        ProfileId = profileId,
                                        ContactId = portalContact.id,
										ASH_Member__c = true
										  );
            insert portalUser;

// 		System.runAs(portalUser) {
// 			test.startTest();
// 			// System.assert(CustomDemographicsController.getContact().Id == contactUser.ContactId);
// //			System.assert(CustomDemographicsController.updateOptIn('Opt-In').Id == portalUser.ContactId);
// 			test.stopTest();
// 		}
	}
	
}
@isTest
	static void getContactNoId(){

		User testUsers = [SELECT Id, contactId FROM User WHERE email = 'testUser1@sfdc1.org' ];
		string portalUserId = testUsers.id;
        string conId = testUsers.ContactId;
		CustomDemographicsController.getContact();
	}
	@isTest
	static void getContactWithId(){

		User portalUser = [SELECT Id, contactId FROM User WHERE email = 'testUser1@sfdc1.org' ];
		string portalUserId = portalUser.id;
		Contact con = [Select Id From Contact where email = 'test@gmail.com'];
		string conId = con.Id;
		System.runAs(portalUser) {CustomDemographicsController.getContact();
		}
	}
	@isTest
	static void udpateOptInNoId(){

		User testUsers = [SELECT Id, contactId FROM User WHERE email = 'testUser1@sfdc1.org' ];
		string portalUserId = testUsers.id;
        string conId = testUsers.ContactId;
		String optIn = 'Opt-In';
		CustomDemographicsController.updateOptIn(optIn);
		}
		@isTest
		static void udpateOptInWithId(){
	
			User portalUser = [SELECT Id, contactId FROM User WHERE email = 'testUser1@sfdc1.org' ];
			// string portalUserId = testUsers.id;
			// string conId = testUsers.ContactId;
			String optIn = 'I do not want to provide Demographic Information';
			System.runAs(portalUser) {CustomDemographicsController.updateOptIn(optIn);
			}
			}
			@isTest
		static void udpateOptInWithIdAlt(){
	
			User portalUser = [SELECT Id, contactId FROM User WHERE email = 'testUser1@sfdc1.org' ];
			// string portalUserId = testUsers.id;
			// string conId = testUsers.ContactId;
			String optIn = 'My data can be used in an identifiable way';
			System.runAs(portalUser) {CustomDemographicsController.updateOptIn(optIn);
			}
			}
}