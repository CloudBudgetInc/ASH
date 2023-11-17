({
  init: function (component, event, helper) {
		const userId = component.get("v.userId");

		if (userId) {
			helper.fetchUser(component)
			.then(function(){})
			.catch(function(){});
		} else {
			helper.fetchCurrentUser(component)
			.then(function(){})
			.catch(function(){});
		}

  }
});