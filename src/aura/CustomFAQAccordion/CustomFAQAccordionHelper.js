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
		const articleAction = component.get("c.getFAQsByTopicId");

		articleAction.setStorable();
		articleAction.setParam("topicId", id);
		articleAction.setCallback(this, function (action) {
			const state = action.getState();
			if (state === "SUCCESS") {
				const articles = action.getReturnValue();
				if (articles) {
					component.set('v.faqs', articles);
				}
			} else {
				console.log("Error occurred", action.getError()[0]);
			}
		});
		$A.enqueueAction(articleAction);
	},
  fetchFAQs: function (component, helper) {
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
	toggleHeader: function(cmp) {
		if ($A.util.hasClass(cmp, "custom-faq__accordionSectionHeader--open")) {
			$A.util.removeClass(cmp, "custom-faq__accordionSectionHeader--open");
		} else {
			$A.util.addClass(cmp, "custom-faq__accordionSectionHeader--open");
		}
	},
	toggleSection: function(cmp, borderColor) {
		if ($A.util.hasClass(cmp, "custom-faq__accordionSection--open")) {
			$A.util.removeClass(cmp, "custom-faq__accordionSection--open");
			$A.util.removeClass(cmp, `custom-faq__accordionSection--open--${borderColor}`);
		} else {
			$A.util.addClass(cmp, "custom-faq__accordionSection--open");
			$A.util.addClass(cmp, `custom-faq__accordionSection--open--${borderColor}`);
		}
	}
})