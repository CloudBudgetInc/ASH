({
	fetchInterests: function(component) {
		const action = component.get("c.getInterests");

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
	loadData: function(component, contact) {
		component.set("v.contact", contact);
		if (contact) {
			if (contact.Clinical_Interests_Multi__c) {
				const clinicalInterests = contact.Clinical_Interests_Multi__c.split(';');
				component.set("v.clinicalInterests", clinicalInterests);
			} else {
				component.set("v.clinicalInterests", []);				
			}

			if (contact.Research_Interests__c) {
				const researchInterests = contact.Research_Interests__c.split(';');
				component.set("v.researchInterests", researchInterests);
			} else {
				component.set("v.researchInterests", []);				
			}
		}
	}
})