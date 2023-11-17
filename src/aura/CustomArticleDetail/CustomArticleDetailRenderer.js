({
  afterRender: function (component, helper) {
    this.superAfterRender();
    // interact with the DOM here
    var event = new Event('addeventatcRefresh');
    setTimeout(function() {
      document.dispatchEvent(event);
    }, 500);
},
})