({
	init: function(component, event, helper) {
		const hash = window.location.hash;
		if (!!hash) {
			component.set('v.selectedTabId', hash.slice(1));
		}

		window.addEventListener("hashchange", function() {
			const hash = window.location.hash;
			if (!!hash) {
				component.set('v.selectedTabId', hash.slice(1));
			}
		}, false);
	}
})