public with sharing class CustomCommitteeMemberSearchController {
  @AuraEnabled(cacheable=false)
	public static List<Attribute__c> searchCommittees(String searchTerm) {
		String wildCardSearchTerm = searchTerm.replaceAll('\\s', '%');
		String searchKey = '%' + wildCardSearchTerm + '%';

		List<Attribute__c> attr = [
			SELECT Category__c,Committee__c,Committee__r.Name,Contact__c, Contact__r.Name,End__c,Id,Start__c,Status__c,Sub_Category__c 
			FROM Attribute__c
			WHERE Category__c = 'Committee' AND Status__c = 'Active'
			AND Committee__c != '0013u0000175AbLAAU' AND Committee__c != '0013u0000175AasAAE'
			AND Contact__r.Name LIKE :searchKey
			ORDER BY Contact__r.Name
			LIMIT 10];

		if (attr.isEmpty()) {
			return null;
		}
		return attr;
	}
}