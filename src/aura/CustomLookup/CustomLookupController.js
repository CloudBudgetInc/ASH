({
  onfocus: function (component, event, helper) {
    const lookupHelp = component.find("lookupHelp");
    $A.util.removeClass(lookupHelp, "slds-show");
    $A.util.addClass(lookupHelp, "slds-hide");

    const lookupField = component.find("lookupField");
    $A.util.removeClass(lookupField, "lookup__error");

    $A.util.addClass(component.find("mySpinner"), "slds-show");
    const forOpen = component.find("searchRes");
    $A.util.addClass(forOpen, "slds-is-open");
    $A.util.removeClass(forOpen, "slds-is-close");
    // Get Default 5 Records order by createdDate DESC
		const getInputkeyWord = "";
    helper.searchHelper(component, event, getInputkeyWord);
  },
  onblur: function (component, event, helper) {
    const getInputkeyWord = document.getElementById('custom-lookup-input').value;
    const selectedRecord = component.get("v.selectedRecord");
		component.set("v.listOfSearchRecords", null);
		const forclose = component.find("searchRes");
		$A.util.addClass(forclose, "slds-is-close");
    $A.util.removeClass(forclose, "slds-is-open");
    
    if (getInputkeyWord.length !== 0 && !selectedRecord.Id) {
      const lookupHelp = component.find("lookupHelp");
      $A.util.addClass(lookupHelp, "slds-show");
      $A.util.removeClass(lookupHelp, "slds-hide");

      const lookupField = component.find("lookupField");
      $A.util.addClass(lookupField, "lookup__error");
    }
  },
  keyPressController: function (component, event, helper) {
    const lookupHelp = component.find("lookupHelp");
    $A.util.removeClass(lookupHelp, "slds-show");
    $A.util.addClass(lookupHelp, "slds-hide");

    const lookupField = component.find("lookupField");
    $A.util.removeClass(lookupField, "lookup__error");

		// get the search Input keyword
    const getInputkeyWord = event.target.value;
    // const getInputkeyWord = component.get("v.SearchKeyWord");
    // check if getInputKeyWord size id more then 0 then open the lookup result List and
    // call the helper
    // else close the lookup result List part.
    if (getInputkeyWord.length > 0) {
      const forOpen = component.find("searchRes");
      $A.util.addClass(forOpen, "slds-is-open");
      $A.util.removeClass(forOpen, "slds-is-close");
      helper.searchHelper(component, event, getInputkeyWord);
    } else {
      component.set("v.listOfSearchRecords", null);
      const forclose = component.find("searchRes");
      $A.util.addClass(forclose, "slds-is-close");
      $A.util.removeClass(forclose, "slds-is-open");
    }
  },

  // function for clear the Record Selaction
  clear: function (component, event, heplper) {
		// debugger;
    const pillTarget = component.find("lookup-pill");
    const lookUpTarget = component.find("lookupField");

    $A.util.addClass(pillTarget, "slds-hide");
    $A.util.removeClass(pillTarget, "slds-show");

    $A.util.addClass(lookUpTarget, "slds-show");
    $A.util.removeClass(lookUpTarget, "slds-hide");

    component.set("v.SearchKeyWord", null);
    component.set("v.listOfSearchRecords", null);
    component.set("v.selectedRecord", {});
  },

  // This function call when the end User Select any record from the result list.
  handleComponentEvent: function (component, event, helper) {
    // get the selected Account record from the COMPONENT event
    const selectedAccountGetFromEvent = event.getParam("recordByEvent");
    component.set("v.selectedRecord", selectedAccountGetFromEvent);

    document.getElementById('custom-lookup-input').value = selectedAccountGetFromEvent.Name;

    const forclose = component.find("lookup-pill");
    $A.util.addClass(forclose, "slds-show");
    $A.util.removeClass(forclose, "slds-hide");

    const searchRes = component.find("searchRes");
    $A.util.addClass(searchRes, "slds-is-close");
    $A.util.removeClass(searchRes, "slds-is-open");

    const lookUpTarget = component.find("lookupField");
    $A.util.addClass(lookUpTarget, "slds-hide");
    $A.util.removeClass(lookUpTarget, "slds-show");
	},
	onSelectedRecordChange: function (component, event, helper) {
		const oldValue = event.getParam("oldValue");
		const newValue = event.getParam("value");

		if (!!newValue.Id && oldValue.Id !== newValue.Id) {
			component.set("v.selectedRecord" , event.getParam("value"));
			
			const forclose = component.find("lookup-pill");
			$A.util.addClass(forclose, "slds-show");
			$A.util.removeClass(forclose, "slds-hide");
			
			const searchRes = component.find("searchRes");
			$A.util.addClass(searchRes, "slds-is-close");
			$A.util.removeClass(searchRes, "slds-is-open");
			
			const lookUpTarget = component.find("lookupField");
			$A.util.addClass(lookUpTarget, "slds-hide");
			$A.util.removeClass(lookUpTarget, "slds-show");
		}
	}
});