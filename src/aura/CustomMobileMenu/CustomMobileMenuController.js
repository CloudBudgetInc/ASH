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
  },
  handleRouteChange: function (component, event, helper) {
		const paths = window.location.pathname.split("/");
		const baseUrl = component.get("v.baseUrl");
		let location = paths[paths.length - 1];
		if (baseUrl === '/ashrc/s/') {
			if (paths.length === 5) {
				location = paths[paths.length - 2] + '-' +  paths[paths.length - 1];
			}
		} else {
			if (paths.length === 4) {
				location = paths[paths.length - 2] + '-' +  paths[paths.length - 1];
			}
		}
    component.set("v.location", location);
  },
});