({
	invoke: function(component, event, helper) {
        const url = component.get("v.url");
       	const urlEvent = $A.get("e.force:navigateToURL");
         const urlRefresh = $A.get('e.force:refreshView');
        urlEvent.setParams({ 
            "url": url
        });
       	
        
        urlEvent.fire();
        window.location.reload();
        
	}
})