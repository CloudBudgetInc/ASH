({
  init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const descriptionField = component.get("v.descriptionField");

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
          const image = helper.getImage(record, helper);
          component.set("v.image", image);
          component.set("v.description", helper.getRichText(descriptionField, record));
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
});