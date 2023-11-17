({
	fetchContact: function (component) {
    const action = component.get("c.getContact");

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
	updateContact: function (component) {
    const action = component.get("c.confirmProfile");

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
})