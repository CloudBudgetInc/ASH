/**
 * Created by mpaquin on 11/20/17.
 */
({
    validateCreateRights : function(component){
        var action = component.get('c.canCreateSponsorShip');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var canCreate = response.getReturnValue();
                if(!canCreate){
                    component.find('createButton').set('v.disabled', true);
                    component.set('v.isInvalid', true);
                    component.set('v.errorMessage', 'Insufficient access, you do not have the right to create sponsorship');
                    console.log('Insufficient access');
                }
            } else if(state === 'ERROR'){
                    component.find('createButton').set('v.disabled', true);
                    component.set('v.isInvalid', true);
                    component.set('v.errorMessage', 'Insufficient access, you do not have the right to create sponsorship');
                console.log('Insufficient access');
            }

        })
        $A.enqueueAction(action);

    },

    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.cityList");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        console.log(reverse);
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.cityList", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    updateFinalAmount : function(component){
        var discountAmount = component.find('discountAmount').get('v.value');
        var totalAmount = component.find('totalAmount').get('v.value');
        var finalAmount = totalAmount - discountAmount;
        component.set('v.finalAmount', finalAmount);
        this.updateAmountPerCity(component);
    },

    updateAmountPerCity : function(component){
        var discountAmount = component.find('discountAmount').get('v.value');
        var totalAmount = component.find('totalAmount').get('v.value');
        var cities = component.find('cities').getSelectedRows();
        var perCityAmount;

        if(cities.length !== 0){
            perCityAmount = (totalAmount - discountAmount) /cities.length;
            component.set('v.amountPerCity', perCityAmount);
        }else{
            component.set('v.amountPerCity', 0);
        }
    },

    validateInput : function(component){

        var isValidInput = true;

        var totalAmountCmp = component.find('totalAmount');
        var totalAmountValue = totalAmountCmp.get('v.value');

        var discountAmountCmp = component.find('discountAmount');
        var discountAmountValue = discountAmountCmp.get('v.value');

        var cityCmp = component.find('cities')
        var cities = cityCmp.getSelectedRows();
        var errorMessage ='';

        if(totalAmountValue === null || !totalAmountCmp.get('v.validity').valid){
            isValidInput = false;
        }
        if(!discountAmountCmp.get('v.validity').valid){
            isValidInput = false;
        }
        if(totalAmountValue <= discountAmountValue){
            errorMessage += ' Total Amount needs to be greater than Discount Amount.';
            isValidInput = false;
        }
        if(cities === null || cities.length === 0){
            errorMessage +=' At least one city must be selected.';
            isValidInput = false;
        }

        if(!isValidInput){
            component.set('v.isInvalid',true);
            component.set('v.errorMessage',errorMessage);
        } else{
            component.set('v.isInvalid',false);
            component.set('v.errorMessage','');
        }
        return isValidInput;
    },

    insertSponsorship : function(component, event, helper){
        var totalAmount = component.find('totalAmount').get('v.value');
        var discountAmount = component.find('discountAmount').get('v.value');
        var cities = component.find('cities').getSelectedRows();
        var parentId = component.get('v.recordId');
        var action = component.get('c.createSponsorship');

        var finalAmount = totalAmount - discountAmount;

        action.setParams({
                          'campaigns' : cities,
                          'amount' : finalAmount,
                          'accountId' : parentId
                            });

        action.setCallback(this, function(response) {
            var state = response.getState();
                            var toastEvent = $A.get('e.force:showToast');
            if(state === 'SUCCESS'){
                var msg = 'The Sponsorship records were created successfully.';
                if(cities.length ===1){
                    msg ='The Sponsorship record was created successfully.';
                }

                toastEvent.setParams({
                    'type':'success',
                    'title': 'Success!',
                    'message': msg
                });
                toastEvent.fire();
                this.dismissActionPanel(component);

            } else if(state === 'ERROR'){
                var errors = response.getError();
                console.log(errors);
                toastEvent.setParams({
                                    'type':'error',
                                    'title': 'Error!',
                                    'message': 'Could not create Sponsorship records the following error was returned: '+errors
                                });
                toastEvent.fire();
                this.dismissActionPanel(component);
            }

        })
        $A.enqueueAction(action);
    },

    dismissActionPanel : function(component){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})