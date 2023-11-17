({
	init: function (component, event, helper) {
		helper.fetchFAQs(component, helper);
	},
	handleAccordion: function(component, event, helper) {
		event.stopPropagation();
		const evId = event.target.id;
    if (evId) {
			const id = evId.split('-')[4];
			const title = component.get('v.title');
			const borderColor = component.get('v.borderColor');
      const accordionHeader = document.getElementById(`custom-faq-accordion-container-${id}-${title}`);
			const accordionSection = document.getElementById(`custom-faq-accordion-${id}-section-${title}`);
      helper.toggleHeader(accordionHeader);
      helper.toggleSection(accordionSection, borderColor);
    }
  },
})