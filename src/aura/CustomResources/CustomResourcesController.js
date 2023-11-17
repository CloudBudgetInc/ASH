({
	init: function(component, event, helper) {
		const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const iconImageField = component.get("v.iconImageField");
    const headlineField = component.get("v.headlineField");
    const descriptionField = component.get("v.descriptionField");
    const resourcesField = component.get("v.resourcesField");

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
          if (iconImageField !== 'None') {
            component.set("v.iconImage", helper.getImage(iconImageField, record, helper));
          }
          component.set("v.headline", helper.getRichText(headlineField, record, false));
          const descriptionDup = headlineField === descriptionField;
          component.set("v.description", helper.getRichText(descriptionField, record, descriptionDup));
          const resourcesDup = resourcesField === headlineField || resourcesField === descriptionField;
          component.set("v.resources", helper.getRichText(resourcesField, record, resourcesDup));
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
	}
})