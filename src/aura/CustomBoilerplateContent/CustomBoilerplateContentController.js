({
	init : function(component, event, helper) {
		const recordId = component.get('v.recordId');
		helper.fetchArticleCategory(component, recordId)
		.then(function(articleCategory) {
			if (articleCategory) {
				component.set('v.categoryType', articleCategory);
			}
			const contentSlug = component.get("v.contentSlug");
			const contentAction = component.get("c.getMContent");
			const bodyField = component.get("v.bodyField");

			contentAction.setStorable();
			contentAction.setParam("language", "en_US");
			contentAction.setParam("contentType", "compact");
			contentAction.setCallback(this, function(action) {
				const state = action.getState();
				if (state === "SUCCESS") {
					const [record] = action.getReturnValue().filter(function(content) {
						return content.contentUrlName === contentSlug;
					});
						if (record) {
						component.set("v.record", record);
						component.set("v.body", helper.getRichText(bodyField, record));
					}
				} else {
					console.log("Error occurred");
				}
			});
			$A.enqueueAction(contentAction);
		}).catch(function() {});
	}
})