({
	fetchUser: function (component) {
    const action = component.get("c.getUser");

    return new Promise(function (resolve, reject) {
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
	},
	fetchSubscriptions: function (component) {
    const action = component.get("c.getSubscriptions");

    return new Promise(function (resolve, reject) {
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
	},
	subscribeAll: function (component, subscribe) {
    const action = component.get("c.subscribeAll");

    return new Promise(function (resolve, reject) {
			action.setParam("subscribe", subscribe);
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
	},
	updateSubscriptions: function (component, updatedContact) {
    const action = component.get("c.updateSubscriptions");

    return new Promise(function (resolve, reject) {
			action.setParam("updatedContact", updatedContact);
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
  },
})