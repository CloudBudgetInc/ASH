({
  cancelLogin: function(component, event, helper) {
    const ev = component.getEvent("cancel");
    ev.fire();
    component.set("v.username", "");
    component.set("v.password", "");
    component.set("v.showError", false);
  },
  handleLogin: function(component, event, helper) {
    const username = component.get("v.username");
    const password = component.get("v.password");
    if (!username) {
      component.set("v.errorMessage", "Username is required.");
      component.set("v.showError", true);
      return;
    }

    if (!password) {
      component.set("v.errorMessage", "Password is required.");
      component.set("v.showError", true);
      return;
    }

    helper
      .doLogin(component)
      .then(function(res) {
        if (res !== null) {
          component.set("v.errorMessage", res);
          component.set("v.showError", true);
        }
      })
      .catch(function(err) {
        component.set(
          "v.errorMessage",
          "An error occurred, please try again later."
        );
        component.set("v.showError", true);
      });
  },
  handleKeyUp: function(component, event, helper) {
    const keyCode = event.getParams().keyCode;
    const username = component.get("v.username");
    const password = component.get("v.password");

    if (keyCode === 13) {
      if (!username) {
        component.set("v.errorMessage", "Username is required.");
        component.set("v.showError", true);
        return;
      }

      if (!password) {
        component.set("v.errorMessage", "Password is required.");
        component.set("v.showError", true);
        return;
      }

      helper
        .doLogin(component)
        .then(function(res) {
          if (res !== null) {
            component.set("v.errorMessage", res);
            component.set("v.showError", true);
          }
        })
        .catch(function(err) {
          component.set(
            "v.errorMessage",
            "An error occurred, please try again later."
          );
          component.set("v.showError", true);
        });
    } else {
      component.set("v.errorMessage", '');
      component.set("v.showError", false);
    }
  }
});