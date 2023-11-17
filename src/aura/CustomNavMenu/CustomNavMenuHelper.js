({
  toggleHeader: function(cmp) {
    if ($A.util.hasClass(cmp, "navMenu__accordionSectionHeader--open")) {
      $A.util.removeClass(cmp, "navMenu__accordionSectionHeader--open");
    } else {
      $A.util.addClass(cmp, "navMenu__accordionSectionHeader--open");
    }
  },
  toggleSection: function(cmp) {
    if ($A.util.hasClass(cmp, "navMenu__accordionSection--open")) {
      $A.util.removeClass(cmp, "navMenu__accordionSection--open");
    } else {
      $A.util.addClass(cmp, "navMenu__accordionSection--open");
    }
  }
});