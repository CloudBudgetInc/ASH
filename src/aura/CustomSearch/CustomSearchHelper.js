({
  doSearch: function(component) {
    const searchText = component.get("v.searchText");
    const ev = component.getEvent("cancel");
    // const action = component.get("c.searchForIds");
    if (searchText) {
      // action.setParams({ searchText: searchText });
      // action.setCallback(this, function(response) {
      //   const state = response.getState();
      //   if (state === "SUCCESS") {
      //     const ids = response.getReturnValue();
      //     sessionStorage.setItem(
      //       "customSearch--recordIds",
      //       JSON.stringify(ids)
      //     );
          const navEvt = $A.get("e.force:navigateToURL");
          const url = `/global-search/${searchText}`;
          navEvt.setParams({ url });
          navEvt.fire();
          ev.fire();
      //   }
      // });
      // $A.enqueueAction(action);
    }
  }
});