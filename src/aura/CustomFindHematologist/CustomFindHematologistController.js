({
	init: function(component, event, helper) {
		helper.fetchContact(component)
		.then(function (contact) {
			component.set('v.contact', contact);

			helper.fetchAddress(component)
			.then(function (address) {
				component.set('v.address', address);
				
				// Set hideNotification
				component.set('v.hideNotification', !!address && !!address.Id);
				
				// Set showOfferings
				component.set('v.showOfferings', contact.FAH_Opt_In__c);
			}).catch(function(error) {
				console.error(error);
			});
		}).catch(function(error) {
			console.error(error);
		});

		helper.checkMember(component)
		.then(function(isMember) {
			component.set('v.isMember', isMember);
		})
		.catch(function(){});
	},
	handleOptIn: function(component, event, helper) {
		const checked = event.target.checked;
		helper.optIn(component, checked)
		.then(function(contact) {
			component.set('v.contact', contact);
			component.set('v.showOfferings', checked);
		})
		.catch(function(){});
	},
	openModal: function(component, event, helper) {
		component.set('v.isModalOpen', true);
		component.set('v.loading', true);
	},
	closeModal: function(component, event, helper) {
		component.set('v.isModalOpen', false);
		component.set('v.loading', false);
	},
	handleError: function(component, event, helper) {
		component.set('v.loading', false);
	},
	setLoadingFalse: function(component, event, helper) {
		component.set('v.loading', false);
	},
	submitDetails: function(component, event, helper) {
		component.set('v.loading', true);
	},
	handleSuccess: function(component, event, helper) {
		component.set('v.isModalOpen', false);
		helper.fetchContact(component)
		.then(function (contact) {
			component.set('v.contact', contact);

			helper.fetchAddress(component)
			.then(function (address) {
				component.set('v.address', address);
				
				// Set hideNotification
				component.set('v.hideNotification', !!address && !!address.Id);
				
				// Set showOfferings
				component.set('v.showOfferings', contact.FAH_Opt_In__c);
			}).catch(function(error) {
				console.error(error);
			});
		}).catch(function(error) {
			console.error(error);
		});
	}
})