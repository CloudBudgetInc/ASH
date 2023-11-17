@IsTest(SeeAllData=true)
public with sharing class ArticleControllerTest {
	@IsTest(SeeAllData=true)
	public static void testArticleController() {
		// getTopics
		List<Topic> topics = ArticleController.getTopics();
		System.assert(topics.size() > 0);

		// getFeaturedTopics
		List<Topic> featuredTopics = ArticleController.getFeaturedTopics();
		System.assert(featuredTopics.size() > 0);

		// getArticleDataCategory
		Knowledge__kav article = new Knowledge__kav(Title='test',urlname='xyz');

		List<Knowledge__DataCategorySelection> categories = ArticleController.getArticleDataCategory(article.Id);
		System.assertEquals(0, categories.size());

		// getArticleById
		List<Knowledge__kav> articles = ArticleController.getArticleById(article.Id);
		System.assertEquals(0, articles.size());

		// getArticlesByTopicId
		Topic topic = new Topic(name='test');
		
		List<Knowledge__kav> articlesByTopic = ArticleController.getArticlesByTopicId(topic.Id);
		System.assertEquals(0, articlesByTopic.size());

		Topic pressRelease = new Topic();
		for (Integer i = 0; i < topics.size(); i++) {
			if (topics[i].Name == 'Press Releases') {
				pressRelease = topics[i];
				break;
			}
		}
		
		List<Knowledge__kav> articlesByExistingTopic = ArticleController.getArticlesByTopicId(pressRelease.Id);
		System.assert(articlesByExistingTopic.size() > 0);		
		System.assertEquals('Online', articlesByExistingTopic.get(0).PublishStatus);

		// getFAQsByTopicId
		List<Knowledge__kav> faqsByTopic = ArticleController.getFAQsByTopicId(topic.Id);
		System.assertEquals(0, faqsByTopic.size());

		List<Knowledge__kav> faqsByTopicValid = ArticleController.getFAQsByTopicId('0TO3u000000UiQWGA0');
		System.assert(faqsByTopicValid.size() > 0);
		
		// getRecordTypeById	
		RecordType recordType = new RecordType(name='test');
		List<RecordType> recordTypes = ArticleController.getRecordTypeById(recordType.Id);
		System.assertEquals(0, recordTypes.size());

		// getRecordTypeById
		TopicAssignment topicAssignment = new TopicAssignment();
		List<TopicAssignment> topicAssignments = ArticleController.getTopicAssignments(topicAssignment.Id);
		System.assertEquals(0, topicAssignments.size());
	}
}