({
	init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const imageField = component.get("v.imageField");
    const topDescriptionField = component.get("v.topDescriptionField");
    const rightDescriptionField = component.get("v.rightDescriptionField");
    const textOnImageField = component.get("v.textOnImageField");
    const textUnderImageField = component.get("v.textUnderImageField");

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
          const image = helper.getImage(imageField, record, helper);
          component.set("v.image", image);
          component.set("v.topDescription", helper.getRichText(topDescriptionField, record, false));
          const rightDup = topDescriptionField === rightDescriptionField;
          component.set("v.rightDescription", helper.getRichText(rightDescriptionField, record, rightDup));
          const textOnDup = textOnImageField === topDescriptionField || textOnImageField === rightDescriptionField;
          component.set("v.textOnImage", helper.getRichText(textOnImageField, record, textOnDup));
          const textUnderDup = textUnderImageField === topDescriptionField || textUnderImageField === rightDescriptionField
          || textUnderImageField === textOnImageField;
          component.set("v.textUnderImage", helper.getRichText(textUnderImageField, record, textUnderDup));
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
})