({
  init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const backgroundImageField = component.get("v.backgroundImageField");
    const subheadingField = component.get("v.subheadingField");
    const col1ImageField = component.get("v.col1ImageField");
    const col2ImageField = component.get("v.col2ImageField");
    const col3ImageField = component.get("v.col3ImageField");
    const col4ImageField = component.get("v.col4ImageField");
    const col1DescriptionField = component.get("v.col1DescriptionField");
    const col2DescriptionField = component.get("v.col2DescriptionField");
    const col3DescriptionField = component.get("v.col3DescriptionField");
    const col4DescriptionField = component.get("v.col4DescriptionField");

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
          if (backgroundImageField !== 'None') {
            const backgroundImage = helper.getImage(backgroundImageField, record, helper);
            component.set("v.backgroundImage", backgroundImage.src);
          }
          component.set(
            "v.subheading",
            helper.getRichText(subheadingField, record)
          );
          component.set("v.col1Image", helper.getImage(col1ImageField, record, helper));
          component.set("v.col2Image", helper.getImage(col2ImageField, record, helper));
          component.set("v.col3Image", helper.getImage(col3ImageField, record, helper));
          component.set("v.col4Image", helper.getImage(col4ImageField, record, helper));
          component.set(
            "v.col1Description",
            helper.getRichText(col1DescriptionField, record, false)
          );
          const col2Dup = col2DescriptionField === col1DescriptionField;
          component.set(
            "v.col2Description",
            helper.getRichText(col2DescriptionField, record, col2Dup)
          );
          const col3Dup =
            col3DescriptionField === col1DescriptionField ||
            col3DescriptionField === col2DescriptionField;
          component.set(
            "v.col3Description",
            helper.getRichText(col3DescriptionField, record, col3Dup)
          );
          const col4Dup =
            col4DescriptionField === col1DescriptionField ||
            col4DescriptionField === col2DescriptionField ||
            col4DescriptionField === col3DescriptionField;
          component.set(
            "v.col4Description",
            helper.getRichText(col4DescriptionField, record, col4Dup)
          );
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
});