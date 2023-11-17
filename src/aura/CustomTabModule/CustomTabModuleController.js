({
	init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const panel1ImageField = component.get("v.panel1ImageField");
    const panel2ImageField = component.get("v.panel2ImageField");
    const panel3ImageField = component.get("v.panel3ImageField");
    const panel4ImageField = component.get("v.panel4ImageField");
    const panel1DescField = component.get("v.panel1DescField");
    const panel2DescField = component.get("v.panel2DescField");
    const panel3DescField = component.get("v.panel3DescField");
    const panel4DescField = component.get("v.panel4DescField");

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
          component.set("v.panel1Image", helper.getImage(panel1ImageField, record, helper));
          component.set("v.panel2Image", helper.getImage(panel2ImageField, record, helper));
          component.set("v.panel3Image", helper.getImage(panel3ImageField, record, helper));
          component.set("v.panel4Image", helper.getImage(panel4ImageField, record, helper));
          component.set("v.panel1Desc", helper.getRichText(panel1DescField, record, false));
          const twoDup = panel2DescField === panel1DescField;
          component.set("v.panel2Desc", helper.getRichText(panel2DescField, record, twoDup));
          const threeDup = panel3DescField === panel1DescField || panel3DescField === panel2DescField;
          component.set("v.panel3Desc", helper.getRichText(panel3DescField, record, threeDup));
          const fourDup = panel4DescField === panel1DescField || panel4DescField === panel2DescField
            || panel4DescField === panel3DescField;
          component.set("v.panel4Desc", helper.getRichText(panel4DescField, record, fourDup));
        }
      } else {
        console.log("Error occurred");
      }
    });
    $A.enqueueAction(contentAction);
  }
})