({
  init: function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const contentAction = component.get("c.getMContent");
    const messageField = component.get("v.messageField");

    // Check cookie
    var cookie = helper.getCookie(contentSlug);
    if (cookie !== "") {
      component.set('v.showBanner', false);
    } else {
      component.set('v.showBanner', true);
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
            component.set("v.message", helper.getRichText(messageField, record));
          }
        } else {
          console.log("Error occurred");
        }
      });
      $A.enqueueAction(contentAction);
    }
  },
	handleClose : function(component, event, helper) {
    const contentSlug = component.get("v.contentSlug");
    const banner = component.find('alertBanner');
    helper.closeBanner(banner, 'alertBanner');
    // Set cookie
    var cookie = helper.getCookie(contentSlug);
    if (cookie !== "") {
      component.set('v.showBanner', false);
    } else {
      // Cookie does not exist
      helper.createCookie(contentSlug);
    }
	}
})