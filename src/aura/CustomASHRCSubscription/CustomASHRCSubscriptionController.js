({
	init: function(component, event, helper) {
		helper.fetchContact(component)
		.then(function (contact) {
			if (contact) {
				component.set('v.contact', contact);
			}
		})
		.catch(function (error) {
			console.error(error);
		});
		component.set('v.submitted', false);
	},
	handleSubscribe: function(component, event, helper) {
		event.preventDefault();
		const subscribe = document.getElementById('subscribe').checked;
        component.set('v.submitted', false);
		component.set('v.loading', true);
		helper.subscribeAll(component, subscribe)
		.then(function (contact) {
			if (contact) {
				component.set('v.contact', contact);
				component.set('v.loading', false);
			}
		})
		.catch(function (error) {
			console.error(error);
		});
	},
})