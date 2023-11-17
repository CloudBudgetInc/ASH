public with sharing class CustomContactSearchController {
    @AuraEnabled(cacheable=false)
	public static List<Contact> searchContacts(String searchTerm, Boolean applyFilter) {
        String searchKey = '%' + searchTerm + '%';
        List<Contact> attr = new List<Contact>();

        if (applyFilter) {
            attr = [SELECT Id, Display_Name__c, ASH_Member__c, MailingAddress
                    FROM Contact
                    WHERE Name LIKE :searchKey
                    AND ASH_Member__c = true
                    LIMIT 10];
        }
        else {
            attr = [SELECT Id, Display_Name__c, ASH_Member__c, MailingAddress
                    FROM Contact
                    WHERE Name LIKE :searchKey
                    LIMIT 10];
        }
           
		if (attr.isEmpty()) {
			return null;
		}
		return attr;
    }
}