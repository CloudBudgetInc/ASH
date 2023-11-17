public with sharing class CustomUserDirectoryController {
	@AuraEnabled(cacheable=true)
	public static List<Contact_Junction__c> getContactJunction() {
		return [
			SELECT Id, 
			Clinical_Trial_Unit__r.Name,
			Clinical_Trial_Unit__r.Consortium__r.Name,
			Clinical_Trial_Unit__r.Primary_Site__r.Name, 
			Clinical_Trial_Unit__r.Primary_Site__r.BillingAddress,
			Address__c,
			Address__r.State__c,
			Contact__c,
			Contact__r.Display_Name__c,
			Contact__r.Name,
			Contact__r.Title, 
			Contact__r.Email,
			Contact__r.Phone,
			Contact_Type__c 
			FROM Contact_Junction__c WHERE Clinical_Trial_Unit__c != ''];
	}
}