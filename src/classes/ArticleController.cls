public with sharing class ArticleController {
	@AuraEnabled(cacheable=true)
	public static List<Topic> getTopics() {
		List<Topic> topics = [SELECT Id, Name FROM Topic WHERE NetworkId = '0DB3u000000g0P4GAI'];
		return topics;
	}

	@AuraEnabled(cacheable=true)
	public static List<Topic> getFeaturedTopics() {
		List<Topic> topics = [SELECT Id,ManagedTopicType,Name FROM Topic WHERE NetworkId = '0DB3u000000g0P4GAI'
			AND ManagedTopicType LIKE '%Featured%' ORDER BY Name ASC NULLS FIRST];
		return topics;
	}

	@AuraEnabled(cacheable=true)
	public static List<TopicAssignment> getTopicAssignments(Id id) {
		List<TopicAssignment> topics = [SELECT EntityId, TopicId FROM TopicAssignment WHERE EntityId =: id];
		return topics;
	}

	@AuraEnabled(cacheable=true)
	public static List<Knowledge__DataCategorySelection> getArticleDataCategory(Id articleId) {
		List<Knowledge__DataCategorySelection> categories =
			[SELECT DataCategoryGroupName, DataCategoryName, Id, ParentId FROM Knowledge__DataCategorySelection WHERE ParentId =: articleId];
		return categories;
	}

	@AuraEnabled(cacheable=true)
	public static List<Knowledge__kav> getArticleById(Id id) {
		List<Knowledge__kav> article = 
		[SELECT Title, Body__c, Boilerplate__c, Publication_Date__c, Snippet__c, Subheading__c, UrlName, Id, KnowledgeArticleId, RecordTypeId,
		Event_Date__c, Speakers__c FROM Knowledge__kav WHERE PublishStatus = 'Online' AND Id =: id];
		return article;
	}

	@AuraEnabled(cacheable=true)
	public static List<RecordType> getRecordTypeById(Id id) {
		List<RecordType> recordType = 
			[SELECT Name FROM RecordType WHERE Id =: id];
		return recordType;
	}

	@AuraEnabled(cacheable=true)
	public static List<Knowledge__kav> getArticlesByTopicId(Id topicId) {
		List<Knowledge__kav> articles = new List<Knowledge__kav>();

		List<TopicAssignment> topicAssignments = [SELECT EntityId FROM TopicAssignment WHERE TopicId =: topicId LIMIT 1000];
		List<Id> topicIds = new List<Id>();
		for (TopicAssignment topicAssignment : topicAssignments) {
			topicIds.add(topicAssignment.EntityId);
		}

		List<KnowledgeArticleVersion> knowledgeArticles = 
			[SELECT KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE Language = 'en_US'
			AND PublishStatus = 'Online' AND Id in :topicIds];

		if (knowledgeArticles.size() > 0) {
			Set<Id> knowledgeIds = new Set<Id>();
			for (KnowledgeArticleVersion knowledgeArticle : knowledgeArticles) {
				knowledgeIds.add(String.valueOf(knowledgeArticle.get('KnowledgeArticleId')));
			}
			List<Knowledge__kav> articleRecords = [SELECT RecordTypeId, KnowledgeArticleId, PublishStatus FROM Knowledge__kav WHERE KnowledgeArticleId IN :knowledgeIds AND PublishStatus = 'Online'];
			System.debug('articleRecords: ' + articleRecords);
			for (Knowledge__kav articleRecord : articleRecords) {
				RecordType recordType = [SELECT Name FROM RecordType WHERE Id =: articleRecord.RecordTypeId];
				System.debug('recordType: ' + recordType);
				if (recordType.Name == 'News') {
					Knowledge__kav news = [SELECT Title, Body__c, Boilerplate__c, Publication_Date__c, Snippet__c, Subheading__c, UrlName, Id, KnowledgeArticleId, RecordTypeId, PublishStatus,
						Summary FROM Knowledge__kav
						WHERE PublishStatus = 'Online' AND KnowledgeArticleId =: articleRecord.KnowledgeArticleId ORDER BY Publication_Date__c DESC];
						articles.add(news);
				}
				else if (recordType.Name == 'Event') {
					Knowledge__kav event =
						[SELECT Title, Body__c, Boilerplate__c, Event_Date__c, Snippet__c, Speakers__c, UrlName, Id, KnowledgeArticleId, RecordTypeId, PublishStatus FROM Knowledge__kav
						WHERE PublishStatus = 'Online' AND KnowledgeArticleId =: articleRecord.KnowledgeArticleId ORDER BY Event_Date__c DESC];
					articles.add(event);
				}
			}
		}
		return articles;
	}

	@AuraEnabled(cacheable=true)
	public static List<Knowledge__kav> getFAQsByTopicId(Id topicId) {
		List<Knowledge__kav> faqs = new List<Knowledge__kav>();

		List<TopicAssignment> topicAssignments = [SELECT EntityId FROM TopicAssignment WHERE TopicId =: topicId LIMIT 1000];
		List<Id> topicIds = new List<Id>();
		for (TopicAssignment topicAssignment : topicAssignments) {
			topicIds.add(topicAssignment.EntityId);
		}

		List<KnowledgeArticleVersion> knowledgeArticles = 
			[SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Language = 'en_US'
			AND PublishStatus = 'Online' AND Id in :topicIds];

		if (knowledgeArticles.size() > 0) {
			Set<Id> knowledgeIds = new Set<Id>();
			for (KnowledgeArticleVersion knowledgeArticle : knowledgeArticles) {
				knowledgeIds.add(String.valueOf(knowledgeArticle.get('KnowledgeArticleId')));
			}
			List<Knowledge__kav> articleRecords = 
				[SELECT RecordTypeId, KnowledgeArticleId FROM Knowledge__kav 
					WHERE KnowledgeArticleId IN :knowledgeIds ORDER BY FirstPublishedDate ASC
				];
			for (Knowledge__kav articleRecord : articleRecords) {
				RecordType recordType = [SELECT Name FROM RecordType WHERE Id =: articleRecord.RecordTypeId];
				if (recordType.Name == 'FAQ') {
					Knowledge__kav event =
						[SELECT Title, Question__c, Answer__c, UrlName, Id, KnowledgeArticleId, RecordTypeId FROM Knowledge__kav
						WHERE PublishStatus = 'Online' AND KnowledgeArticleId =: articleRecord.KnowledgeArticleId];
						faqs.add(event);
				}
			}
		}
		return faqs;
	}
}