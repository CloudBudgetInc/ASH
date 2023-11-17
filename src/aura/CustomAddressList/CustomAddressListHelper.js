({
	fetchAddresses: function(component) {
		const action = component.get("c.getAddresses");
		
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
	fetchContactId: function(component) {
		const action = component.get("c.getContactId");
		
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
	// fetchAccountId: function(component) {
	// 	const action = component.get("c.getAccountId");
		
	// 	return new Promise(function(resolve, reject) {
	// 		action.setCallback(this, function(response) {
	// 			const state = response.getState();
	// 			if (state === "SUCCESS") {
	// 				resolve(response.getReturnValue());
	// 			} else {
	// 				reject(response.getError()[0]);
	// 			}
	// 		});
	// 		$A.enqueueAction(action);
	// 	});
	// },
	removeAddress: function(component, id) {
		const action = component.get("c.removeAddressById");
		component.set("v.loading", true);
		
		return new Promise(function(resolve, reject) {
			action.setParam('id', id);
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
	sortAddresses: function(addresses) {
		if (addresses) {
			addresses.sort(function(addr1, addr2) {
				var main1 = addr1.Main__c;
				var main2 = addr2.Main__c;
	
				var billing1 = addr1.Billing__c;
				var billing2 = addr2.Billing__c;
				
				var shipping1 = addr1.Shipping__c;
				var shipping2 = addr2.Shipping__c;
	
				if (main1 < main2) return 1;
				if (main1 > main2) return -1;
				if (billing1 < billing2) return 1;
				if (billing1 > billing2) return -1;
				if (shipping1 < shipping2) return 1;
				if (shipping1 > shipping2) return -1;
				return 0;
			});
		}
		return addresses;
	}
})