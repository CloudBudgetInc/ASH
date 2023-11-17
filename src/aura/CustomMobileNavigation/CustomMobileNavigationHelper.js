({
	toggleHeader: function(cmp) {
		if ($A.util.hasClass(cmp, "mobile-nav__accordionSectionHeader--open")) {
			$A.util.removeClass(cmp, "mobile-nav__accordionSectionHeader--open");
		} else {
			$A.util.addClass(cmp, "mobile-nav__accordionSectionHeader--open");
		}
	},
	toggleSection: function(cmp) {
		if ($A.util.hasClass(cmp, "mobile-nav__accordionSection--open")) {
			$A.util.removeClass(cmp, "mobile-nav__accordionSection--open");
		} else {
			$A.util.addClass(cmp, "mobile-nav__accordionSection--open");
		}
	}
});