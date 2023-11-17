({
  handleCancel: function(component, event, helper) {
    const ev = component.getEvent("cancel");
    ev.fire();
    component.set("v.searchText", "");
  },
  handleSearch: function(component, event, helper) {
    helper.doSearch(component);
  },
  handleKeyUp: function(component, event, helper) {
    const keyCode = event.getParams().keyCode;
    if (keyCode === 13) {
      helper.doSearch(component);
    }
  }
});