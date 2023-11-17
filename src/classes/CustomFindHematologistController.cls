public with sharing class CustomFindHematologistController {
	@AuraEnabled 
	public static Contact getContact() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}

		Contact contact = 
			[SELECT Id, FAH_Opt_In__c, Accept_New_Patients__c, Perform_Case_Reviews__c,
				Provide_Second_Opinions__c, Clinical_Interests_Multi__c, OtherPhone
				FROM Contact WHERE Id =: user.ContactId];

		return contact;
	}

	@AuraEnabled 
	public static Address__c getAddress() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}
		
		Address__c address = 
			[SELECT Billing__c, Person__c, Id, Main__c, City__c, PostalCode__c, Country_Lookup__r.Name,
				State__c, Street2__c, Street__c, Country_Lookup__c, Shipping__c, Member_Directory__c,
				Address_Type__c, Address_Status__c, Find_a_Hematologist__c
				FROM Address__c
				WHERE Person__c =: user.ContactId AND Find_a_Hematologist__c = true AND Address_Status__c != 'Inactive' ];

		if (address == null) {
			return null;
		}
		return address;
	}

	@AuraEnabled
	public static Boolean checkMemberStatus() {
		User user = [SELECT Id, ASH_Member__c FROM User WHERE Id =: UserInfo.getUserId()];
		return user.ASH_Member__c;
	}

	@AuraEnabled
	public static Contact updateOptIn(Boolean optedIn) {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];

		if (user.ContactId == null) {
			return null;
		}

		Contact contact = 
			[SELECT Id, Accept_New_Patients__c, Perform_Case_Reviews__c, FAH_Opt_In__c,
				Provide_Second_Opinions__c, Clinical_Interests_Multi__c, OtherPhone
			FROM Contact WHERE Id =: user.ContactId];

		contact.FAH_Opt_In__c = optedIn;
		update contact;
		return contact;
	}
}