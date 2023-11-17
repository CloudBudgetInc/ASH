({
  init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const headingField = component.get("v.headingField");
    const subheadingField = component.get("v.subheadingField");

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
          const backgroundImage = helper.getImage(record, helper);
          component.set("v.backgroundImage", backgroundImage.src);
          component.set("v.heading", helper.getRichText(headingField, record));
          component.set("v.subheading", helper.getRichText(subheadingField, record));
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
});