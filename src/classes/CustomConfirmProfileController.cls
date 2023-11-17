public with sharing class CustomConfirmProfileController {
  @AuraEnabled 
	public static Contact getContact() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}

		Contact contact = 
			[SELECT Id, Profile_Last_Confirmed__c FROM Contact WHERE Id =: user.ContactId];

		return contact;
	}

	@AuraEnabled 
	public static Id confirmProfile() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}

		Contact contact = 
			[SELECT Id, Profile_Last_Confirmed__c FROM Contact WHERE Id =: user.ContactId];

		contact.Profile_Last_Confirmed__c = System.now();

		update contact;

		Attribute__c attribute = new Attribute__c(
			Category__c = 'Profile Confirmation',
			Contact__c = user.ContactId,
			Start__c = System.now().date()
		);

		insert attribute;

		return attribute.Id;
	}
}