({
	toggleHeader: function(cmp) {
		if ($A.util.hasClass(cmp, "mobile-menu__accordionSectionHeader--open")) {
			$A.util.removeClass(cmp, "mobile-menu__accordionSectionHeader--open");
		} else {
			$A.util.addClass(cmp, "mobile-menu__accordionSectionHeader--open");
		}
	},
	toggleSection: function(cmp) {
		if ($A.util.hasClass(cmp, "mobile-menu__accordionSection--open")) {
			$A.util.removeClass(cmp, "mobile-menu__accordionSection--open");
		} else {
			$A.util.addClass(cmp, "mobile-menu__accordionSection--open");
		}
	}
});