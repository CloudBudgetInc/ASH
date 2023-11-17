/**
 * Created by mpaquin on 11/20/17.
 */
({

    insertSponsorship : function(component, event, helper){
        var totalAmount = component.find('sponsorshipAmount').get('v.value');
        var year = component.find('sponsorshipYear').get('v.value');
        var cities = component.find('sponsorshipCities').getSelectedRows();
        var parentId = component.get('v.recordId');
        var action = component.get('c.createSponsorship');

        action.setParams({
                          'campaigns' : cities,
                          'year' : year,
                          'amount' : amount,
                          'accountId' : parentId
                            });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){


            } else if(state === 'ERROR'){
                var errors = response.getError();
                console.log(errors);
            }

        })
        $A.enqueueAction(action);
    },
})