({
  fetchArticle: function (component, helper) {
    const articleAction = component.get("c.getArticleById");
    const recordId = component.get("v.recordId");

		articleAction.setStorable();
    articleAction.setParam("id", recordId);
    articleAction.setCallback(this, function (action) {
      const state = action.getState();
      if (state === "SUCCESS") {
				const [article] = action.getReturnValue();
        if (article) {
          helper.fetchRecordType(component, article.RecordTypeId)
          .then(function(recordType) {
            Object.assign(article, {RecordType: recordType[0].Name});
            if (article.Body__c) {
              const domain = window.location.hostname.replace(/\./g, '\\.');
              const regex = new RegExp(`(<a href=")(http|https)(:\/\/${domain}\\/[^]+?)(" target=")(_blank)(")`, 'gm');
              article.Body__c = article.Body__c.replace(regex, '$1$2$3$4_self$6');
            }
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
              component.set("v.article", article);
            })
            .catch(function() {});
          })
          .catch(function() {});
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(articleAction);
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
          console.log("Error occurred");
					reject(action.getError()[0]);
        }
      });
      $A.enqueueAction(articleAction);
    });
  }
});