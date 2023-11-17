({
	invoke : function(component, event, helper) {
		const retUrl = component.get('v.url');
		const redirect = $A.get('e.force:navigateToURL');
		redirect.setParams({
			url: retUrl
		});
		redirect.fire();
	}
})