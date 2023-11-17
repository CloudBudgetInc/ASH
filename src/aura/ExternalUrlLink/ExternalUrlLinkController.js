({
	invoke: function(component, event, helper) {
        const url = component.get("v.url");
       	//const urlEvent = $A.get("e.force:navigateToURL");
        //urlEvent.setParams({ 
        //    "url": url
        //});
       	//urlEvent.fire();
       	window.open(url,'_blank');
	}
})