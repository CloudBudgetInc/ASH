({
  handleAnchor: function(component, event, helper) {
    event.preventDefault();
    const linkId = event.target.id;

    const anchorId = helper.getAnchorId(component, linkId);
    const articleListElement = document.getElementById(`article-list-${anchorId}`);
    if (articleListElement) {
      helper.scrollTo(articleListElement);
    }

    const headingCTAElement = document.getElementById(`heading-cta-${anchorId}`);
    if (headingCTAElement) {
      helper.scrollTo(headingCTAElement);
    }
  }
})