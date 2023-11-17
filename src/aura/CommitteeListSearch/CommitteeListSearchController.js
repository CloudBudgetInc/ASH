({
    onInit: function( component, event, helper ) {
        // proactively search on component initialization
        const searchTerm = component.get( "v.searchTerm" );
        const selectCustClass = component.find( "customerClass" ).get("v.value");
        const showOnlyActive = component.get( "v.commStatus" );

        const action = component.get( "c.getCustomerClasses" );
        action.setParams({});
        action.setCallback(this, function(response){
            const state = response.getState();
            if (state === "SUCCESS") {
                const customerClasses = response.getReturnValue();
                component.set("v.customerClasses", customerClasses);
            }
        });
        $A.enqueueAction(action);

        helper.handleSearch( component, searchTerm, selectCustClass, showOnlyActive);
    },
    onSearchTermChange: function( component, event, helper ) {
        // search anytime the term changes
        let searchTerm = component.get( "v.searchTerm" );
        let selectCustClass = component.find( "customerClass" ).get("v.value");
        let showOnlyActive = component.get("v.commStatus");

        // to improve performance, particularly for fast typers,
        // we wait a small delay to check when user is done typing
        const delayMillis = 500;
        // get timeout id of pending search action
        let timeoutId = component.get( "v.searchTimeoutId" );
        // cancel pending search action and reset timer
        clearTimeout( timeoutId );
        // delay doing search until user stops typing
        // this improves client-side and server-side performance
        timeoutId = setTimeout( $A.getCallback( function() {
            helper.handleSearch( component, searchTerm, selectCustClass, showOnlyActive);
        }), delayMillis );

        component.set( "v.searchTimeoutId", timeoutId );
    },
    onCustomerClassChanged: function(component, event,helper){
        const searchTerm = component.get( "v.searchTerm" );
        const selectCustClass = component.find( "customerClass" ).get("v.value");
        const showOnlyActive = component.get( "v.commStatus" );

        helper.handleSearch( component, searchTerm, selectCustClass, showOnlyActive);
    },
    onStatusChange: function(component, event, helper) {
        const searchTerm = component.get( "v.searchTerm" );
        const selectCustClass = component.find( "customerClass" ).get("v.value");
     
        let currentStatus = component.get("v.commStatus");
        component.set('v.commStatus', !currentStatus);

        helper.handleSearch( component, searchTerm, selectCustClass, !currentStatus);
    }
})