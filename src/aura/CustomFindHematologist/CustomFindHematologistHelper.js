({
	fetchContact: function(component) {
		const action = component.get('c.getContact');
		
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
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
	fetchAddress: function(component) {
		const action = component.get('c.getAddress');
		
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
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
	checkMember: function(component) {
		const action = component.get("c.checkMemberStatus");

		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
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
	optIn: function(component, optedIn) {
		const action = component.get('c.updateOptIn');

		return new Promise(function(resolve, reject) {
			action.setParam('optedIn', optedIn);
			action.setCallback(this, function(response) {
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
})