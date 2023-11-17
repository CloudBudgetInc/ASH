({
  handleAccordion: function(cmp, event, helper) {
    event.stopPropagation();
    const evId = event.target.id;
    if (evId) {
      const id = evId.split('-')[2];
      const accordionHeader = document.getElementById(`accordion-container-${id}`);
      const accordionSection = document.getElementById(`accordion-${id}-section`);
      helper.toggleHeader(accordionHeader);
      helper.toggleSection(accordionSection);
    }
  },
  onClick : function(component, event, helper) {
    var id = event.target.dataset.menuItemId;
		if (id) {
			component.getSuper().navigate(id);
		}
	}
});