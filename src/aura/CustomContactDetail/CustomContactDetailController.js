({
	init: function(component, event, helper) {
		helper.fetchContact(component)
		.then(function(contact) {
			component.set("v.contact", contact);
			helper.resetEffortBar();
		})
		.catch(function(){});
		helper.checkMember(component)
		.then(function(isMember) {
			component.set("v.isMember", isMember);
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
		helper.fetchContact(component).then(function(contact) {
			component.set("v.contact", contact);
			helper.resetEffortBar();
		})
		.catch(function(){});
	},
	handleError: function(component, event, helper) {
		component.set("v.loading", false);
	},
	setLoadingFalse: function(component, event, helper) {
		component.set("v.loading", false);
	},
	submitDetails: function(component, event, helper) {
		component.set("v.loading", true);
	},
	handleMemberUpdate: function(component, event, helper) {
		const checked = event.target.checked;
		helper.updateMemberDirectory(component, checked)
		.then(function(contact) {})
		.catch(function(){});
	}
})