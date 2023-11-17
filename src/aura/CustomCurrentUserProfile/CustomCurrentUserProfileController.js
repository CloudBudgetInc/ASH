({
	init: function(component, event, helper) {
		helper.fetchContact(component)
		.then(function(contact) {
			component.set("v.contact", contact);

			helper.resetEffortBar();
		})
		.catch(function(){});
	},
	openModal: function(component, event, helper) {
		component.set("v.isModalOpen", true);
		component.set("v.loading", true);
	},
	closeModal: function(component, event, helper) {
		component.set("v.isModalOpen", false);
		component.set("v.loading", false);
	},
	setLoadingFalse: function(component, event, helper) {
		component.set("v.loading", false);
	},
	submitDetails: function(component, event, helper) {
		component.set("v.loading", true);
	},
	handleSuccess: function(component, event, helper) {
		component.set("v.isModalOpen", false);
		component.set("v.loading", false);
		helper.fetchContact(component)
		.then(function(contact) {
			component.set("v.contact", contact);

			helper.resetEffortBar();
		})
		.catch(function(){});
	}
})