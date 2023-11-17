public with sharing class CustomResourceListController {
	@AuraEnabled(cacheable=true)
	public static List<ContentVersion> getContentVersions() {
    List<ContentVersion> contentVersions = 
      [SELECT Id, ContentDocumentId, LastModifiedDate, FileExtension, FileType, Title, VersionNumber
        FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN (SELECT ContentDocumentId FROM ContentDistribution)
        ORDER BY LastModifiedDate DESC
      ];

		if (contentVersions.isEmpty()) {
			return null;
		}
		return contentVersions;
  }

  @AuraEnabled(cacheable=true)
	public static ContentDistribution getContentDistributionById(Id id) {
		List<ContentDistribution> dist = [
      SELECT Id, ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl
      FROM ContentDistribution WHERE ContentDocumentId =: id
    ];

    if (dist.isEmpty()) {
      return null;
    }
    return dist[0];
  }

  @AuraEnabled(cacheable=true)
	public static List<ContentDocument> getContentDocumentsByLibrary(Id libraryId) {
    List<ContentDocument> docs = [
      SELECT Id, ParentId FROM ContentDocument WHERE ParentId =: libraryId
    ];

    if (docs.isEmpty()) {
      return null;
    }
    return docs;
  }
}