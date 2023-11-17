({
	init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const iconImageField = component.get("v.iconImageField");
    const headlineField = component.get("v.headlineField");
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
          if (iconImageField !== 'None') {
            component.set("v.iconImage", helper.getImage(record, helper));
          }
					component.set("v.headline", helper.getRichText(headlineField, record, false));
          const bodyDup = headlineField === bodyField;
          component.set("v.body", helper.getRichText(bodyField, record, bodyDup));
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  },
  handleSortFilter: function(component, event, helper) {
  }
})