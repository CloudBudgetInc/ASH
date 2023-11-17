({
    // code in the helper is reusable by both
    // the controller.js and helper.js files
    handleSearch: function( component, searchText, selectCustClass, showOnlyActive) {
        var action = component.get( "c.getCommittees" );
        var custClass = '';

        if(selectCustClass != undefined){
            custClass = selectCustClass;
        }

        // set params
        action.setParams({
            searchText: searchText,
            customerClass: custClass,
            showOnlyActive: showOnlyActive
        });
        
        action.setCallback( this, function( response ) {
            var event = $A.get( "e.c:CommitteeListLoaded" );
            var accounts = response.getReturnValue();
            accounts.forEach(function(account){
                account.linkName = '/'+account.Id;
            });
            event.setParams({
                "accounts": accounts
            });
            event.fire();
        });
        $A.enqueueAction( action );
    }
})