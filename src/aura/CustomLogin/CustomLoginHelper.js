({
  doLogin: function(cmp) {
    const usernameInput = cmp.find("username__input");
    const username = cmp.get("v.username");
    const password = cmp.get("v.password");
    var startUrl = cmp.get("v.startUrl");
    const action = cmp.get("c.doLogin");
    if (username && password) {
      startUrl = decodeURIComponent(startUrl);
      return new Promise(function(resolve, reject) {
        action.setParams({ username, password, startUrl: '/s/portal' });
        action.setCallback(this, function(response) {
          const state = response.getState();
          const value = response.getReturnValue();
          if (state === "SUCCESS") {
            resolve(response.getReturnValue());
          } else {
            const errors = response.getError();
            reject(response.getError()[0]);
          }
        });
        $A.enqueueAction(action);
      });
    }
  }
});