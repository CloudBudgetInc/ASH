({
	fetchTopics: function (component) {
    const articleAction = component.get("c.getTopics");

    articleAction.setStorable();
		return new Promise(function(resolve, reject) {
			articleAction.setCallback(this, function (action) {
				const state = action.getState();
				if (state === "SUCCESS") {
					resolve(action.getReturnValue());
				} else {
					console.log("Error occurred");
					reject(action.getError()[0]);
				}
			});
			$A.enqueueAction(articleAction);
		});
	},
	fetchTopicAssignments: function (component, id) {
    const articleAction = component.get("c.getTopicAssignments");

    articleAction.setStorable();
    articleAction.setParam("id", id);
		return new Promise(function(resolve, reject) {
			articleAction.setCallback(this, function (action) {
				const state = action.getState();
				if (state === "SUCCESS") {
					resolve(action.getReturnValue());
				} else {
					console.log("Error occurred");
					reject(action.getError()[0]);
				}
			});
			$A.enqueueAction(articleAction);
		});
	},
	fetchArticleCategory: function (component, id) {
		const articleAction = component.get("c.getArticleDataCategory");

    articleAction.setStorable();
    articleAction.setParam("articleId", id);
		return new Promise(function(resolve, reject) {
			articleAction.setCallback(this, function (action) {
				const state = action.getState();
				if (state === "SUCCESS") {
					resolve(action.getReturnValue());
				} else {
					console.log("Error occurred", action.getError()[0]);
					reject(action.getError()[0]);
				}
			});
			$A.enqueueAction(articleAction);
		});
	},
	fetchRecordType: function (component, id) {
    const articleAction = component.get("c.getRecordTypeById");

		articleAction.setStorable();
    articleAction.setParam("id", id);
		return new Promise(function(resolve, reject) {
      articleAction.setCallback(this, function (action) {
        const state = action.getState();
        if (state === "SUCCESS") {
          resolve(action.getReturnValue())
        } else {
          console.log("Error occurred", action.getError()[0]);
					reject(action.getError()[0]);
        }
      });
      $A.enqueueAction(articleAction);
    });
	},
	fetchArticlesByTopic: function (component, helper, id) {
		const articleAction = component.get("c.getArticlesByTopicId");
		const pageSize = component.get('v.limit');

		articleAction.setStorable();
		articleAction.setParam("topicId", id);
		articleAction.setCallback(this, function (action) {
			const state = action.getState();
			if (state === "SUCCESS") {
				const articles = action.getReturnValue();
				if (articles) {
					articles.forEach(function(article, index) {
						helper.fetchRecordType(component, article.RecordTypeId)
						.then(function(recordType) {
							Object.assign(article, {RecordType: recordType[0].Name});

							helper.fetchArticleCategory(component, article.Id)
							.then(function(dataCategories) {
								const [articleCategory] = dataCategories.filter(function(category) {
									return category.DataCategoryGroupName === 'Article_Type'
								}).map(function(category) {
									return category.DataCategoryName.replace('_', ' ');
								});
								Object.assign(article, {Category: articleCategory});

								const [articleAudience] = dataCategories.filter(function(audience) {
									return audience.DataCategoryGroupName === 'Audience'
								}).map(function(audience) {
									return audience.DataCategoryName.replace('_', ' ');
								});
								Object.assign(article, {Audience: articleAudience});

								if (index === articles.length - 1) {
									component.set('v.articles', articles);
									const filteredArticles = articles
										.sort(function(u1, u2) {
											return helper.sortByField(u1, u2, 'Date', 'DESC', helper);
											// return helper.sortByField(u1, u2, sortBy, sortDir, helper);
										})
										.slice(0, pageSize);
									if (articles.length <= pageSize) {
										helper.hideButton(component);
									} else {
										helper.showButton(component);
									}
									component.set('v.filteredArticles', filteredArticles);
								}
							})
							.catch(function() {});
						})
						.catch(function() {});
					});
				}
			} else {
				console.log("Error occurred", action.getError()[0]);
			}
		});
		$A.enqueueAction(articleAction);
	},
  fetchArticles: function (component, helper) {
		const topicName = component.get("v.topic");
		const topicId = component.get("v.topicId");

		if (topicId) {
			helper.fetchArticlesByTopic(component, helper, topicId);
		}

		helper.fetchTopics(component)
		.then(function(topics) {
			const [topic] = topics.filter(function(t) {
				return t.Name === topicName;
			});
			if (topic) {
				helper.fetchArticlesByTopic(component, helper, topic.Id);
			}
		})
		.catch(function(err) {
			console.error(err);
		});
	},
	hideButton: function(cmp) {
		window.setTimeout(
			$A.getCallback(function() {
			const viewMoreBtn = cmp.find('viewMore');
			$A.util.addClass(viewMoreBtn, "is-hidden");
		}), 200);
	},
	showButton: function(cmp) {
		window.setTimeout(
			$A.getCallback(function() {
			const viewMoreBtn = cmp.find('viewMore');
			$A.util.removeClass(viewMoreBtn, "is-hidden");
		}), 200);
	},
	getField: function(field, article) {
		if (field == 'Date') {
			if (article.Publication_Date__c) {
				return new Date(article.Publication_Date__c);
			}
			return new Date(article.Event_Date__c);
		}
	},
	sortByField: function(u1, u2, sortField, sortDir, helper) {
		const article1 = helper.getField(sortField, u1);
		const article2 = helper.getField(sortField, u2);
		if (article1 === article2) {
      return 0;
    }
    // NULLS go last.
    if (article1 === null) {
      return 1;
    }
    if (article2 === null) {
      return -1;
    }
		// Sort by ascending price.
		if (sortDir === 'ASC') {
			return article1 < article2 ? -1 : 1;
		}
    return article1 < article2 ? 1 : -1;
	}
});