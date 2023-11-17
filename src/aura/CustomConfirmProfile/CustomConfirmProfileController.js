({
	init: function (component, event, helper) {
    helper
      .fetchContact(component)
      .then(function (contact) {
        component.set("v.contact", contact);
      })
      .catch(function (error) {
        console.error(error);
      });
  },
	handleConfirmProfile: function(component, event, helper) {
		helper
		.updateContact(component)
		.then(function (id) {
			helper
      .fetchContact(component)
      .then(function (contact) {
        component.set("v.contact", contact);
      })
      .catch(function (error) {
        console.error(error);
      });
		})
		.catch(function (error) {
			console.error(error);
		});
	}
})