({
  onPlayerReady: function(event) {
      event.target.playVideo();
  },
  onPlayerStateChange: function(event, component) {
    // on video end, update user record
    if (event.data === 0) {
      const action = component.get("c.updateLLSAuth");
        action.setCallback(this, function(response) {
           const state = response.getState();
            if (state === "SUCCESS") {
                const storeResponse = response.getReturnValue();
                //window.location.href = "/s/lls-train";
            }
        });
        $A.enqueueAction(action);
    }
  }
});