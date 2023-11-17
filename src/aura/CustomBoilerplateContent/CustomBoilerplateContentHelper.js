({
	fetchArticleCategory: function (component, id) {
		const articleAction = component.get("c.getArticleDataCategory");

    articleAction.setStorable();
    articleAction.setParam("articleId", id);
		return new Promise(function(resolve, reject) {
			articleAction.setCallback(this, function (action) {
				const state = action.getState();
				if (state === "SUCCESS") {
					const dataCategories = action.getReturnValue();
					const [articleCategory] = dataCategories.filter(function(category) {
						return category.DataCategoryGroupName === 'Article_Type'
					}).map(function(category) {
						return category.DataCategoryName;
					});
					resolve(articleCategory);
				} else {
					console.log("Error occurred", action.getError()[0]);
					reject(action.getError()[0]);
				}
			});
			$A.enqueueAction(articleAction);
		});
	},
  getRichText: function(field, record) {
    var textResult = record;
    var dom = document.createElement("div");
    const domain = window.location.hostname.replace(/\./g, '\\.');
    const regex = new RegExp(`(;a href=&quot;)(http|https)(:\/\/${domain}\\/[^]+?)(&quot; target=&quot;)(_blank)(&quot;)`, 'gm');

    if (field === "Headline") {
      if (textResult.contentNodes.Headline) {
        dom.innerHTML = textResult.contentNodes.Headline.value;
        textResult.contentNodes.Headline.value = dom.innerText;
        return textResult.contentNodes.Headline.value;
      }
    } else if (field === "Rich Text Field 1") {
      if (textResult.contentNodes.CompactBody1) {
        dom.innerHTML = textResult.contentNodes.CompactBody1.value.replace(
          regex,
          '$1$2$3$4_self$6'
        );
        textResult.contentNodes.CompactBody1.value = dom.innerText;
        return textResult.contentNodes.CompactBody1.value;
      }
    } else if (field === "Rich Text Field 2") {
      if (textResult.contentNodes.CompactBody2) {
        dom.innerHTML = textResult.contentNodes.CompactBody2.value.replace(
          regex,
          '$1$2$3$4_self$6'
        );
        textResult.contentNodes.CompactBody2.value = dom.innerText;
        return textResult.contentNodes.CompactBody2.value;
      }
    }
    return "";
  }
})