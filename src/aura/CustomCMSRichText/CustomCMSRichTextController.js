({
  init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const contentField = component.get("v.contentField");
    const backgroundImageField = component.get("v.backgroundImageField");
    const bottomTextField = component.get("v.bottomTextField");

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
          component.set("v.content", helper.getRichText(contentField, record));
          const dup = bottomTextField === contentField;
          component.set("v.bottomText", helper.getRichText(bottomTextField, record, dup));
          if (backgroundImageField !== 'None') {
            const backgroundImage = helper.getImage(record, helper);
            component.set("v.backgroundImage", backgroundImage.src);
          }
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
});