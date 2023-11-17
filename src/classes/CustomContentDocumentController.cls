public with sharing class CustomContentDocumentController {
	@AuraEnabled 
	public static Id getContactId() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		return user.ContactId;
	}

  @AuraEnabled 
	public static List<ContentDocument> getContentDocuments() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}

		List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: user.ContactId];

		if (docLinks.isEmpty()) {
			return null;
		}

		List<ContentDocument> contentDocs = new List<ContentDocument>();
		for (ContentDocumentLink docLink : docLinks) {
			ContentDocument doc = [SELECT LatestPublishedVersionId, LastModifiedDate, FileExtension, FileType, Id, Title FROM ContentDocument WHERE Id =: docLink.ContentDocumentId];

			contentDocs.add(doc);
		}

		if (contentDocs.isEmpty()) {
			return null;
		}
		return contentDocs;
	}

	@AuraEnabled 
	public static List<ContentVersion> getContentVersions() {
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
		}

		List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: user.ContactId];

		if (docLinks.isEmpty()) {
			return null;
		}

		List<ContentVersion> contentVersions = new List<ContentVersion>();
		for (ContentDocumentLink docLink : docLinks) {
			ContentDocument doc = [SELECT LatestPublishedVersionId, FileExtension, FileType, Id, Title FROM ContentDocument WHERE Id =: docLink.ContentDocumentId];

			ContentVersion version = [SELECT ContentDocumentId, Description, LastModifiedDate, Type__c FROM ContentVersion WHERE Id =: doc.LatestPublishedVersionId];

			contentVersions.add(version);
		}

		if (contentVersions.isEmpty()) {
			return null;
		}
		return contentVersions;
	}
}