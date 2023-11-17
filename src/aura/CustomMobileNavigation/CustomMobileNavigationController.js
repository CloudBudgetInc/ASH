({
  init: function(component) {
    window.addEventListener("scroll", function (e) {
      const scrollTop =
        window.pageYOffset ||
        document.documentElement.scrollTop ||
        document.body.scrollTop;
      component.set("v.scrolled", scrollTop > 0);
    });
  },
  handleAccordion: function(cmp, event, helper) {
    event.stopPropagation();
    const accordionHeader = document.getElementById('accordion-container-contact');
    const accordionSection = document.getElementById('accordion-contact-section');
    helper.toggleHeader(accordionHeader);
    helper.toggleSection(accordionSection);
  }
});