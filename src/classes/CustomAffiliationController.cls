public with sharing class CustomAffiliationController {
  @AuraEnabled 
	public static List<Affiliate__c> getAffiliations() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}
		
		List<Affiliate__c> affiliations = 
			[SELECT Active__c, Contact__c, End_Date__c, Id, Role__c, Start_Date__c, Type1__c, Primary__c,
				Related_Organization__r.Name, Related_Organization__r.BillingCity, Related_Organization__r.BillingState,
				Pending_Record__c, Pending_Record__r.Organization_Name__c, OwnerId
				FROM Affiliate__c
				WHERE Type__c != 'DUPLICATE' AND Related_Organization__c != null AND Contact__c =: user.ContactId
				ORDER BY Start_Date__c DESC];

		if (affiliations.isEmpty()) {
			return null;
		}
		return affiliations;
	}

	@AuraEnabled 
	public static List<Affiliate__c> getAffiliatedStaff() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}
		
		List<Affiliate__c> affiliations = 
			[SELECT Related_Contact__c, Related_Contact__r.FirstName, Related_Contact__r.LastName, Related_Contact__r.npe01__WorkEmail__c, 
				Related_Contact__r.npe01__WorkPhone__c, Active__c, Start_Date__c, End_Date__c, Pending_Record__c, Pending_Record__r.First_Name__c,
				Pending_Record__r.Last_Name__c, Pending_Record__r.Email__c, Pending_Record__r.Phone__c, Pending_Record__r.Related_Organization__c
				FROM Affiliate__c
				WHERE Type__c = 'Staff' AND Contact__c =: user.ContactId
				ORDER BY Start_Date__c DESC];

		if (affiliations.isEmpty()) {
			return null;
		}
		return affiliations;
	}

	@AuraEnabled 
	public static Id getContactId() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}
		return user.ContactId;
	}

	@AuraEnabled 
	public static Id getCurrentUserId() {
		return UserInfo.getUserId();
	}

	@AuraEnabled 
	public static Id deleteAffiliationById(Id id) {
		Affiliate__c deleteAffiliation = [SELECT Id FROM Affiliate__c WHERE Id =: id];

		if (deleteAffiliation != null) {
			delete deleteAffiliation;
			return id;
		}
		return null;
	}

	@AuraEnabled
	public static PenRec__c getPendingOrg(Id id) {
		PenRec__c pendingOrg = [
			SELECT Organization_Name__c, First_Name__c, Last_Name__c, Email__c, Phone__c, Related_Organization__C
			FROM PenRec__c WHERE Id =: id
		];
		return pendingOrg;
	}
}