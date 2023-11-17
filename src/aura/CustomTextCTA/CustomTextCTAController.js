({
	init: function(component, event, helper) {
		const contentSlug = component.get("v.contentSlug");
		const contentAction = component.get("c.getMContent");
		const headlineField = component.get("v.headlineField");
		const contentField = component.get("v.contentField");

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
					component.set("v.headline", helper.getRichText(headlineField, record, false));
					const contentDup = contentField === headlineField;
					component.set("v.content", helper.getRichText(contentField, record, contentDup));
				}
			} else {
				console.log("Error occurred");
			}
		});
		$A.enqueueAction(contentAction);
	}
})