({
	init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const leftHeadlineField = component.get("v.leftHeadlineField");
    const rightHeadlineField = component.get("v.rightHeadlineField");
    const leftDescriptionField = component.get("v.leftDescriptionField");
		const rightDescriptionField = component.get("v.rightDescriptionField");

    contentAction.setStorable();
    contentAction.setParam("language", "en_US");
    contentAction.setParam("contentType", "full");
    contentAction.setCallback(this, function(action) {
			const state = action.getState();
      if (state === "SUCCESS") {
        const [record] = action.getReturnValue().filter(function(content) {
          return content.contentUrlName === contentSlug;
				});
        if (record) {
					component.set("v.record", record);
          component.set("v.leftHeadline", helper.getRichText(leftHeadlineField, record, false));
          const rightDup = rightHeadlineField === leftHeadlineField;
          component.set("v.rightHeadline", helper.getRichText(rightHeadlineField, record, rightDup));
          const leftDup = leftDescriptionField === rightHeadlineField || leftDescriptionField === leftHeadlineField;
          component.set("v.leftDescription", helper.getRichText(leftDescriptionField, record, leftDup));
          const rightDescDup = rightDescriptionField === leftDescriptionField ||
						rightDescriptionField === rightHeadlineField || rightDescriptionField === leftHeadlineField;
          component.set("v.rightDescription", helper.getRichText(rightDescriptionField, record, rightDescDup));
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
})