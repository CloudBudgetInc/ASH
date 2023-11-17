({
  init: function(component, event, helper) {
		helper.fetchInterests(component)
		.then(function(contact) {
			helper.loadData(component, contact);
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

		helper.fetchInterests(component).then(function(contact) {
			helper.loadData(component, contact);
		})
		.catch(function(error) {
			console.error(error);
		});
	},
	setLoadingFalse: function(component, event, helper) {
		component.set("v.loading", false);
	},
	submitDetails: function(component, event, helper) {
		component.set("v.loading", true);
	}
})