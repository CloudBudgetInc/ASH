({
  updateIndicators: function(currentIndex) {
    const indicators = document.getElementsByClassName(
      "slds-carousel__indicator-action"
    );
    Array.prototype.forEach.call(indicators, function(indicator, index) {
      if (indicator.id) {
        if (indicator.id === `indicator-id-${currentIndex}`) {
          indicator.classList.add("slds-is-active");
        } else {
          indicator.classList.remove("slds-is-active");
        }
      }
    });
  },
  getRecords: function(component) {
    const contentAction = component.get("c.getMContent");
    contentAction.setStorable();
    const maxItems = component.get("v.maxItems");
    return new Promise(function(resolve, reject) {
      contentAction.setParam("language", "en_US");
      contentAction.setParam("contentType", "testimonial");
      contentAction.setCallback(this, function(action) {
        const state = action.getState();
        if (state === "SUCCESS") {
          var records = [];
          if (maxItems && Number(maxItems) > 0) {
            records = action.getReturnValue().slice(0, Number(maxItems));
          } else {
            records = action.getReturnValue();
          }
          if (records) {
            component.set("v.records", records);
            resolve(records);
          }
        } else {
          console.log("Error occurred");
          reject(action.getError()[0]);
        }
      });
      $A.enqueueAction(contentAction);
    });
  }
});