({
	init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const backgroundImageField = component.get("v.backgroundImageField");
    const subheadingField = component.get("v.subheadingField");
    const firstCardField = component.get("v.firstCardField");
    const secondCardField = component.get("v.secondCardField");
    const thirdCardField = component.get("v.thirdCardField");

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
          const image = helper.getImage(backgroundImageField, record, helper);
          component.set("v.backgroundImage", image.src);
          component.set("v.firstCard", helper.getRichText(firstCardField, record, false));
          const secondDup = firstCardField === secondCardField;
          component.set("v.secondCard", helper.getRichText(secondCardField, record, secondDup));
          const thirdDup = thirdCardField === firstCardField || secondCardField === thirdCardField;
          component.set("v.thirdCard", helper.getRichText(thirdCardField, record, thirdDup));
          const subheadingDup = subheadingField === firstCardField || subheadingField === secondCardField
          || subheadingField === thirdCardField;
          component.set("v.subheading", helper.getRichText(subheadingField, record, subheadingDup));
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
})