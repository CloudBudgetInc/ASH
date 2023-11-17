({
    onCommitteeListLoad: function( component, event, helper ) {
        var cols = [
            {
                label: 'Committee Name', 
                fieldName: 'linkName', type: 'url', 
                typeAttributes: {
                    label: { fieldName: 'Name' }, 
                    target: '_self'}},
            {
                label: 'Customer Class',
                fieldName: 'Class__c',
                type: 'text'
            },
            {
                label: 'Personify Id',
                fieldName: 'Personify_ID__c',
                type: 'text'
            },
            {
                label: 'Status',
                fieldName: 'Status__c',
                type: 'text'
            }
        ];
        component.set( 'v.cols', cols );
        component.set( 'v.rows', event.getParam( 'accounts' ) );
        
    },
    onRowAction: function( component, event, helper ) {
        var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        if ( action.name == 'view_details' ) {
            var navigation = component.find( 'navigation' );
            navigation.navigate({
                'type': 'standard__recordPage',
                'attributes': {
                    'objectApiName': 'Account',
                    'recordId': row.Id,
                    'actionName': 'view'
                }
            });
        }
    }
})