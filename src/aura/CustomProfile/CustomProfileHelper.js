({
	fetchUser: function(component) {
		const action = component.get("c.getCurrentUser");

		action.setStorable();
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
	fetchContactJunction: function(component, id, recordType) {
		if (recordType === 'User') {
			const action = component.get("c.getContactJunctionByUser");

			action.setStorable();
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
		} else {
			const action = component.get("c.getContactJunctionById");
	
			action.setStorable();
			return new Promise(function(resolve, reject) {
				action.setParams({ id });
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
		}
	},
	// fetchCurrentContactJunctionId: function(component) {
	// 	const action = component.get("c.getContactJunctionIdByUser");

	// 	action.setStorable();
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
	fetchContactUser: function(component, id) {
		const action = component.get("c.getUserById");

		return new Promise(function(resolve, reject) {
			action.setParams({ id });
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
	fetchContactAddress: function(component, contactId, ctuId) {
		const action = component.get("c.getAddressByContactJunction");

		return new Promise(function(resolve, reject) {
			action.setParams({ contactId, ctuId });
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
	fetchProfileImage: function(component, userId) {
		const action = component.get("c.getProfileImage");

		return new Promise(function(resolve, reject) {
			action.setParam('userId', userId);
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
	upload: function(component, file, base64Data) {
		const action = component.get("c.uploadProfileImage");

		return new Promise(function(resolve, reject) {
			action.setParams({
				base64Data: base64Data, 
				contentType: file.type,
				fileName: file.name
			});
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
	mappedContactUser: function(contactUser) {
		let credentials = '';
		if (contactUser.Credentials__c) {
			credentials = contactUser.Credentials__c.split(';').join(', ');
		}
		return {
			AboutMe: contactUser.AboutMe,
			Credentials__c: credentials,
			FirstName: contactUser.FirstName,
			Id: contactUser.Id,
			LastName: contactUser.LastName,
			Phone: contactUser.Phone,
			Salutation__c: contactUser.Salutation__c,
			SenderEmail: contactUser.SenderEmail,
			Show_Email__c: contactUser.Show_Email__c,
			Show_Phone__c: contactUser.Show_Phone__c,
			Title: contactUser.Title
		}
	}
})