({
  getAnchorId: function(component, linkId) {
    var anchorId = '';
    if (linkId === 'headline-link-1') {
      anchorId = component.get('v.headline1AnchorId');
    }
    if (linkId === 'headline-link-2') {
      anchorId = component.get('v.headline2AnchorId');
    }
    if (linkId === 'headline-link-3') {
      anchorId = component.get('v.headline3AnchorId');
    }
    if (linkId === 'headline-link-4') {
      anchorId = component.get('v.headline4AnchorId');
    }
    return anchorId;
  },
  scrollTo: function(el) {
    const top = (el.getBoundingClientRect().top + window.pageYOffset) - 150;

      window.scrollTo({
        top,
        behavior: 'smooth'
      })
  }
})