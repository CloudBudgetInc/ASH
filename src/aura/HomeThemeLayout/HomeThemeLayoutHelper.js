({
  enableButton: function (cmp) {
    $A.util.removeClass(cmp, "theme-layout__mainHeader-button--disabled");
  },
  disableButton: function (cmp) {
    $A.util.addClass(cmp, "theme-layout__mainHeader-button--disabled");
  },
  disableScroll: function () {
    document.body.style.overflowY = "hidden";
  },
  enableScroll: function () {
    document.body.style.overflowY = "scroll";
  },
  fetchUser: function (cmp) {
    const action = cmp.get("c.fetchUser");
    action.setStorable();
    action.setCallback(this, function (response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        const res = response.getReturnValue();
        cmp.set("v.member", res.FirstName + ' ' + res.LastName);
        cmp.set("v.userId", res.Id);
      }
    });
    $A.enqueueAction(action);
  },
  checkIsLoggedIn: function (cmp) {
    const action = cmp.get("c.isLoggedIn");
    action.setStorable();
    action.setCallback(this, function (response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        const res = response.getReturnValue();
        cmp.set("v.loggedIn", res);
      }
    });
    $A.enqueueAction(action);
  }
});