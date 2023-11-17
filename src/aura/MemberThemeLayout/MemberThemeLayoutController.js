({
  init: function (component, event, helper) {
    helper.fetchUser(component);
    helper.checkIsLoggedIn(component);
  },
  handleRouteChange: function (component, event, helper) {
    const paths = window.location.pathname.split("/");
    const location = paths[paths.length - 1];
    component.set("v.location", location);
    component.set("v.menuOpen", false);
    helper.enableScroll();
  },
  onMenuChange: function(cmp, evt) {
    console.log("parentAttr has changed");
    console.log("old value: " + evt.getParam("oldValue"));
    console.log("current value: " + evt.getParam("value"));
  }
});