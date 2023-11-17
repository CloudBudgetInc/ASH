({
  fetchContact: function (component) {
    const action = component.get('c.getContact');

    return new Promise(function (resolve, reject) {
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === 'SUCCESS') {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
	},
	subscribeAll: function (component, subscribe) {
    const action = component.get('c.subscribeAll');
    return new Promise(function (resolve, reject) {
			action.setParam('subscribe', subscribe);
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === 'SUCCESS') {
					component.set('v.error', '');
					component.set('v.submitted', true);
          resolve(response.getReturnValue());
        } else {
					component.set('v.submitted', false);
					component.set('v.error', 'An error occurred and your submission failed. Please try again later.');
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
	},
})