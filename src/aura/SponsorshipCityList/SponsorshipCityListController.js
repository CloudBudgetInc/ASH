/**
 * Created by mpaquin on 11/20/17.
 */
({
    doInit : function (component, event, helper){
        var getCities = component.get('c.getCities');

        getCities.setCallback(this, function(response){
            var cities = response.getReturnValue();
            component.set('v.cityList', cities);
        })
        $A.enqueueAction(getCities);
    },
})