({
	onClick : function(component, event, helper) {
		var id = event.target.dataset.menuItemId;
		if (id) {
			component.getSuper().navigate(id);
		}
	},
	handleRouteChange: function (component, event, helper) {
		const paths = window.location.pathname.split("/");
		const baseUrl = component.get("v.baseUrl");
		let location = paths[paths.length - 1];
		if (baseUrl === '/ashrc/s/') {
			if (paths.length === 5) {
				location = paths[paths.length - 2] + '-' +  paths[paths.length - 1];
			}
		} else {
			if (paths.length === 4) {
				location = paths[paths.length - 2] + '-' +  paths[paths.length - 1];
			}
		}
    component.set("v.location", location);
  },
 })