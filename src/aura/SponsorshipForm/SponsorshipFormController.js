/**
 * Created by mpaquin on 11/20/17.
 */
({
    init : function(component, event, helper){
        var columns = [{label: 'City', fieldName: 'City_State_and_Continent__c', sortable: 'true'},
                        {label: 'Year', fieldName: 'Campaign_Year__c', sortable: 'true'}];
        component.set('v.dataTableColumns', columns);
        helper.validateCreateRights(component);
    },

    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    closeModal : function(component, event, helper){
        helper.dismissActionPanel(component);
    },

    rowSelected : function(component, event, helper){
        var cityList = component.get('v.cityList');
        var selectedCities = component.find('cities').getSelectedRows();
        var discountAmountCmp = component.find('discountAmount');
        var discountAmountValue = discountAmountCmp.get('v.value');
        var totalAmountValue = component.find('totalAmount').get('v.value');

        if(selectedCities !== undefined && cityList !== undefined){
            if(cityList.length === selectedCities.length && selectedCities.length !== 0){
                discountAmountCmp.set('v.value', 2500);
                helper.updateFinalAmount(component);
                helper.updateAmountPerCity(component);
            } else{
                discountAmountCmp.set('v.value', 0);
                helper.updateFinalAmount(component);
                helper.updateAmountPerCity(component);
            }
        }
    },

    amountChange : function(component, event, helper){
      helper.updateFinalAmount(component);
    },

    submitSponsorship : function(component, event, helper){
        var isInputValid = helper.validateInput(component);
        if(isInputValid){
            helper.insertSponsorship(component, event, helper);
        }
    },
})