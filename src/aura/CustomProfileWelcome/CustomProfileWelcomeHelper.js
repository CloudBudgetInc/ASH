({
	fetchCurrentUser: function(component) {
		const action = component.get("c.getCurrentUser");

		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === "SUCCESS") {
					const user = response.getReturnValue();
					component.set("v.user", user);
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	fetchUser: function(component) {
		const action = component.get("c.getUserById");
		const userId = component.get("v.userId");

		return new Promise(function(resolve, reject) {
			action.setParam('id', userId);
			action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === "SUCCESS") {
					const user = response.getReturnValue();
					component.set("v.user", user);
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	}
})