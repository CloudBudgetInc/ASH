public with sharing class CustomLookupController {
	@AuraEnabled
	public static List<sObject> fetchLookUpValues(String searchKeyWord, String ObjectName) {
		System.debug('ObjectName-->' + ObjectName);
		String searchKey = searchKeyWord + '%';
		
		List<sObject> returnList = new List <sObject>();
	
		// Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10   
		String sQuery = 'SELECT Id, Name FROM ' + ObjectName + ' WHERE Name LIKE: searchKey ORDER BY createdDate DESC LIMIT 10';
		List<sObject> lstOfRecords = Database.query(sQuery);
		
		for (sObject obj: lstOfRecords) {
			returnList.add(obj);
		}
		return returnList;
	}
}