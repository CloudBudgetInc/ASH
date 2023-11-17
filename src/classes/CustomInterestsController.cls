public with sharing class CustomInterestsController {
	@AuraEnabled 
	public static Contact getInterests() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}

		Contact contact = 
			[SELECT toLabel(Clinical_Interests_Multi__c), Id, toLabel(Research_Interests__c) FROM Contact WHERE Id =: user.ContactId];

		return contact;
	}
}