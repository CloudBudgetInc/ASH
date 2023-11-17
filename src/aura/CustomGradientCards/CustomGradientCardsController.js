({
  init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const leftImageField = component.get("v.leftImageField");
    const rightImageField = component.get("v.rightImageField");
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
					if (leftImageField !== 'None') {
						component.set("v.leftImage", helper.getImage(leftImageField, record, helper));
					}
					if (rightImageField !== 'None') {
						component.set("v.rightImage", helper.getImage(rightImageField, record, helper));
					}
          component.set(
            "v.leftHeadline",
            helper.getRichText(leftHeadlineField, record, false)
          );
          const rightHeadlineDup = leftHeadlineField === rightHeadlineField;
          component.set(
            "v.rightHeadline",
            helper.getRichText(rightHeadlineField, record, rightHeadlineDup)
          );
          const leftDup =
            leftDescriptionField === leftHeadlineField ||
            leftDescriptionField === rightHeadlineField;
          component.set(
            "v.leftDescription",
            helper.getRichText(leftDescriptionField, record, leftDup)
          );
          const rightDup =
            rightDescriptionField === leftHeadlineField ||
            rightDescriptionField === rightHeadlineField ||
            rightDescriptionField === leftDescriptionField;
          component.set(
            "v.rightDescription",
            helper.getRichText(rightDescriptionField, record, rightDup)
          );
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
});