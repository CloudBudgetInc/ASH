public with sharing class CustomASHRCSubscriptionController {
	@AuraEnabled 
	public static Contact getContact() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}
		
		Contact contact = 
			[SELECT FirstName, LastName, Email, ASHRC_Email__c FROM Contact WHERE Id =: user.ContactId];

		return contact;
	}

	@AuraEnabled 
	public static Contact subscribeAll(Boolean subscribe) {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}
		
		Contact contact = [SELECT Id, ASHRC_Email__c FROM Contact WHERE Id =: user.ContactId];

		try {
			contact.ASHRC_Email__c = subscribe;
			update contact;
		} catch (DmlException e) {
			System.debug('An unexpected error has occurred: ' + e.getMessage());
			throw e;
		}

		Contact updatedContact = 
			[SELECT FirstName, LastName, Email, ASHRC_Email__c FROM Contact WHERE Id =: user.ContactId];

		if (updatedContact == null) {
			return null;
		}

		return updatedContact;
	}
}