({
	init: function (component, event, helper) {
		/* Listen for scroll */
		window.addEventListener("scroll", function (e) {
      const scrollTop =
        window.pageYOffset ||
        document.documentElement.scrollTop ||
        document.body.scrollTop;
      component.set("v.scrolled", scrollTop > 0);
    });

		/* Listen for click event */
		window.addEventListener("mouseup", function (e) {
      const mobileMenu = document.getElementById('mobile-menu');
      const search = document.getElementById('search');
			const login = document.getElementById('login');

      /* Close mobile menu on outside click */
      if (e.target !== mobileMenu && e.target.parentNode !== mobileMenu) {
				if (e.target.id !== 'menu-btn' && !!e.target.className && 
					!e.target.className.startsWith('mobile-menu')
					|| (!!e.target.parentNode.className
          && !e.target.parentNode.className.startsWith('mobile-menu')
          && !e.target.parentNode.className.startsWith('mobile-nav')
          && !e.target.className.startsWith('mobile-nav'))) {
					component.set("v.menuOpen", false);
        }
			}

			/* Close search on outside click */
			if (e.target !== search && e.target.parentNode !== search) {
				if (e.target.id !== 'search-btn' && !!e.target.className &&
					!e.target.className.startsWith('search')
					|| (!!e.target.parentNode.className
          && !e.target.parentNode.className.startsWith('search'))) {
					component.set("v.searchOpen", false);
					// helper.toggleOverlay(false);
        }
			}

			/* Close login on outside click */
			if (e.target !== login && e.target.parentNode !== login) {
				if (e.target.id !== 'login-btn' && !!e.target.className &&
					!e.target.className.startsWith('login')
					|| (!!e.target.parentNode.className
          && !e.target.parentNode.className.startsWith('login'))) {
					component.set("v.loginOpen", false);
					// helper.toggleOverlay(false);
        }
			}
		});
	},
	openMenu: function (component, event, helper) {
    const menuOpen = component.get("v.menuOpen");
    component.set("v.searchOpen", false);
    component.set("v.loginOpen", false);
		component.set("v.menuOpen", !menuOpen);
	},
	openSearch: function (component, event, helper) {
		const searchOpen = component.get("v.searchOpen");
    component.set("v.loginOpen", false);
		component.set("v.menuOpen", false);
		component.set("v.searchOpen", !searchOpen);
		// helper.toggleOverlay(!searchOpen);
	},
	openLogin: function (component, event, helper) {
		const loginOpen = component.get("v.loginOpen");
    component.set("v.searchOpen", false);
    component.set("v.menuOpen", false);
		component.set("v.loginOpen", !loginOpen);
		// helper.toggleOverlay(!loginOpen);
	},
	handleLoginClose: function (component, event, helper) {
		component.set("v.searchOpen", false);
    component.set("v.menuOpen", false);
		component.set("v.loginOpen", false);
		// helper.toggleOverlay(false);
	},
	handleSearchClose: function (component, event, helper) {
    component.set("v.loginOpen", false);
		component.set("v.menuOpen", false);
		component.set("v.searchOpen", false);
		// helper.toggleOverlay(false);
	},
	onNavClick : function(component, event, helper) {
		var id = event.target.dataset.menuItemId;
		if (id) {
			component.getSuper().navigate(id);
		}
	},
	onMenuOpenChange: function(component, event, helper) {
		const currentlyOpen = event.getParam("value");
		if (currentlyOpen) {
			document.body.style.overflowY = "hidden";
		} else {
			document.body.style.overflowY = "scroll";
		}
		helper.toggleOverlay(currentlyOpen);
	},
	handleRouteChange: function (component, event, helper) {
		const paths = window.location.pathname.split("/");
		const baseUrl = component.get("v.baseUrl");
		let location = paths[paths.length - 1];
		if (baseUrl === '/ashrc/s/') {
			if (paths.length === 5) {
				location = paths[paths.length - 2] + '-' +  paths[paths.length - 1] + window.location.hash;
			}
		} else {
			if (paths.length === 4) {
				location = paths[paths.length - 2] + '-' +  paths[paths.length - 1 ]+ window.location.hash;
			}
		}
    component.set("v.location", location);
  },
 })