({
  onYouTubePlayerAPIReady: function(component, event, helper) {
    var player;
    if (window.YT) {
    	player = new window.YT.Player("player", {
        events: {
          onReady: helper.onPlayerReady,
          onStateChange: function (e) {
              helper.onPlayerStateChange(e, component);
          }
        }
      });
    }
  }
});