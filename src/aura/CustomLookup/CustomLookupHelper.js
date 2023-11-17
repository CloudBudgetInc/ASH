({
  searchHelper: function (component, event, getInputkeyWord) {
    // call the apex class method
    const action = component.get("c.fetchLookUpValues");
    // set param to method
    action.setParams({
      searchKeyWord: getInputkeyWord,
      ObjectName: component.get("v.objectAPIName")
    });
    // set a callBack
    action.setCallback(this, function (response) {
      $A.util.removeClass(component.find("mySpinner"), "slds-show");
			const state = response.getState();
      if (state === "SUCCESS") {
				const storeResponse = response.getReturnValue();
        // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
        if (storeResponse.length == 0) {
          component.set("v.Message", "No Result Found...");
        } else {
          component.set("v.Message", "");
        }
				// set searchResult list with return value from server.
        component.set("v.listOfSearchRecords", storeResponse);
      } else {
				console.log('error', response.getError()[0]);
				reject(response.getError()[0]);
			}
    });
    // enqueue the Action
    $A.enqueueAction(action);
  }
});