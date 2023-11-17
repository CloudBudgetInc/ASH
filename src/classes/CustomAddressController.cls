public with sharing class CustomAddressController {
  @AuraEnabled 
	public static List<Address__c> getAddresses() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}
		
		List<Address__c> address = 
			[SELECT Billing__c, Person__c, Id, Main__c, City__c, PostalCode__c, Country_Lookup__r.Name,
				State__c, Street2__c, Street__c, Country_Lookup__c, Shipping__c, Member_Directory__c,
				Address_Type__c, Address_Status__c, Find_a_Hematologist__c
				FROM Address__c
				WHERE Person__c =: user.ContactId AND Address_Status__c != 'BAD' ];

		if (address.isEmpty()) {
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
	public static Id getContactId() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}
		return user.ContactId;
	}

	@AuraEnabled 
	public static Id getAccountId() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}

		Contact contact = [SELECT AccountId FROM Contact WHERE Id =: user.ContactId];

		if (contact == null || contact.AccountId == null) {
			return null;
		}

		return contact.AccountId;
	}

	@AuraEnabled 
	public static Id removeAddressById(Id id) {
		Address__c addr = [SELECT Id, Address_Status__c FROM Address__c WHERE Id =: id];

		if (addr != null) {
			addr.Address_Status__c = 'BAD';
			update addr;
			return id;
		}
		return null;
	}
}