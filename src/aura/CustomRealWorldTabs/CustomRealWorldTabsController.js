({
	init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
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

		// Open to tab
		// window.addEventListener('hashchange', function() {
		// 	const hash = window.location.hash;
		// 	if (!!hash) {
		// 		component.set("v.tabId", hash.slice(1));
		// 	}
		// });
  },
	handleChange: function(component) {
		//Display content on the Item Three tab
		var selected = component.get("v.tabId");
		component.find("tabs").set("v.selectedTabId", selected);
	}
})