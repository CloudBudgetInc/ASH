({
  toggleOverlay: function(open) {
    if (open) {
      document.body.id = 'body-overlay';
    } else {
      document.body.id = "";
    }
  }
})