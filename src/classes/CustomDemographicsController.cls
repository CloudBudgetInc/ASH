public with sharing class CustomDemographicsController {
	@AuraEnabled 
	public static Contact getContact() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}

		Contact contact = 
			[SELECT Id, Birthdate, Gender__c, Gender_Expanded__c, COB__c, COB__r.Name, COR__c,
				Gender_Self_Describe__c, Pronouns__c, Pronouns_Self_Describe__c,
				Orientation__c, Orientation_Self_Describe__c, Disability__c,
				Disabililty_Self_Describe__c, Ethnicity__c, Ethnicity_Self_Identify__c,
				DEI_Opt_In__c, IsNA__c, Demographic_Information_Selection__c
				FROM Contact WHERE Id =: user.ContactId];

		return contact;
	}

	@AuraEnabled
	public static Contact updateOptIn(String optIn) {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];

		if (user.ContactId == null) {
			return null;
		}

		Contact contact = [SELECT Id, DEI_Opt_In__c, Demographic_Information_Selection__c FROM Contact WHERE Id =: user.ContactId];

//		contact.DEI_Opt_In__c = optIn;
		if(optIn == 'I do not want to provide Demographic Information'){
			contact.Demographic_Information_Selection__c = optIn;
			contact.DEI_Opt_In__c = 'Opt-Out';
			update contact;
			

		}
		else{
			contact.Demographic_Information_Selection__c = optIn;
			contact.DEI_Opt_In__c = 'Opt-In';
			update contact;

		}
		return contact;
		
	}

}