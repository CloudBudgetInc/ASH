public with sharing class CustomASHRCDirectoryController {
	@AuraEnabled(cacheable=true)
	public static List<Contact_Junction__c> getCTNContactJunctions() {
		return [
			SELECT Id,
			Clinical_Trial_Unit__c,
			Clinical_Trial_Unit__r.Name,
			Clinical_Trial_Unit__r.Consortium__c,
			Clinical_Trial_Unit__r.Consortium__r.Name,
			Clinical_Trial_Unit__r.Learning_Community__c,
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

	@AuraEnabled(cacheable=true)
	public static List<Contact_Junction__c> getDHContactJunctions() {
		return [
			SELECT Id,
			Data_Hub_Contributor__c,
			Data_Hub_Contributor__r.Name,
			Data_Hub_Contributor__r.Data_Hub_Program__c,
			Data_Hub_Contributor__r.Data_Hub_Program__r.Name,
			Data_Hub_Contributor__r.Learning_Community__c,
			Address__c,
			Address__r.State__c,
			Contact__c,
			Contact__r.Display_Name__c,
			Contact__r.Name,
			Contact__r.Title, 
			Contact__r.Email,
			Contact__r.Phone,
			Contact_Type__c 
			FROM Contact_Junction__c WHERE Data_Hub_Contributor__c != ''];
	}
}