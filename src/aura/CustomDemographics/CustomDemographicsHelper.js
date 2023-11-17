({
  fetchContact: function(component) {
		const action = component.get("c.getContact");

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
	optIn: function(component, optIn) {
		const action = component.get("c.updateOptIn");

		return new Promise(function(resolve, reject) {
			action.setParam("optIn", optIn);
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
	setOptIn: function(contact) {
		// if (contact.DEI_Opt_In__c === 'Opt-In') {
		// 	return true;
		// }
		// return false;
		return contact.DEI_Opt_In__c;
	},
	setDemographic: function(contact) {
		// if (contact.DEI_Opt_In__c === 'Opt-In') {
		// 	return true;
		// }
		// return false;
		return contact.Demographic_Information_Selection__c;
	}
})