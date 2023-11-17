({
	init : function(component, event, helper) {
		const sortBy = component.get('v.sortBy');
		const sortDir = component.get('v.sortDir');
		const pageSize = component.get('v.pageSize');
		helper.fetchContacts(component)
			.then(function(res) {
				if (res) {
					res.sort(function(u1, u2) {
						return helper.sortByField(u1, u2, sortBy, sortDir, helper);
					});
	
					component.set('v.filteredContacts', res);
					const displayContacts = res.slice(0, pageSize);
					component.set('v.displayContacts', displayContacts);
					helper.createFilters(component, res);
					
					// Create Pagination
					helper.createPagination(component, helper, res.length);
				}
			})
			.catch(function(err) {});
	},
	handleSort: function(component, event, helper) {
		const pageSize = component.get('v.pageSize');
		const contacts = component.get('v.contacts');
		const filter = component.get('v.filter');
		const sortBy = event.getSource().get('v.name');
		const value = event.getSource().get('v.value');
		const searchText = component.get('v.searchText');

		var sortDir = value;
		const fields = ['Name', 'Role', 'Consortium', 'State', 'CTU'];

		fields.forEach(function(field) {
			const btn = component.find(`${field}-label`);
			if (field !== sortBy) {
				if (btn) {
					btn.set('v.value', '');
				}
			}
		});

		if (value === 'DESC' || value === '') {
			event.getSource().set('v.value', 'ASC');
			component.set('v.sortDir', 'ASC');
			sortDir = 'ASC';
		} else {
			event.getSource().set('v.value', 'DESC');
			component.set('v.sortDir', 'DESC');
			sortDir = 'DESC';
		}

		component.set('v.sortBy', sortBy);
		let filtered = helper.filter(component, contacts, filter)
			.sort(function(u1, u2) {
				return helper.sortByField(u1, u2, sortBy, sortDir, helper);
			})

		if (searchText) {
			filtered = helper.filterSearch(contacts, searchText)
				.sort(function(u1, u2) {
					return helper.sortByField(u1, u2, sortBy, sortDir, helper);
				});
		}
		component.set('v.filteredContacts', filtered);
			// Handle page size
		helper.createPagination(component, helper, filtered.length);
		const displayContacts = filtered.slice(0, pageSize);
		component.set('v.displayContacts', displayContacts);
		component.set('v.currentPage', 1);
	},
	handleFilter: function(component, event, helper) {
		const sortBy = component.get('v.sortBy');
		const sortDir = component.get('v.sortDir');
		const contacts = component.get('v.contacts');
		const filter = component.get('v.filter');
		const pageSize = component.get('v.pageSize');
		const field = event.getSource().get('v.name').split('_')[0];
		const menuItems = component.find(`${field}Items`);
		const clearItem = component.find(`clear${field}`);
		const selectedMenuItemValue = event.getParam('value');
		const btn = component.find(`${field}-filter`);

		const sortedContacts = contacts.sort(function(u1, u2) {
			return helper.sortByField(u1, u2, sortBy, sortDir, helper);
		});
		
		if (selectedMenuItemValue === 'clear') {
			if (menuItems.length) {
				menuItems.forEach(function(menuItem) {
					menuItem.set('v.checked', false);
				});
			} else {
				menuItems.set('v.checked', false);
			}
			delete filter[field];
			component.set('v.filter', filter);
			const filtered = helper.filter(component, sortedContacts, filter)
				.sort(function(u1, u2) {
					return helper.sortByField(u1, u2, sortBy, sortDir, helper);
				});
			component.set('v.filteredContacts', filtered);
			
			// Handle page size
			helper.createPagination(component, helper, filtered.length);
			const displayContacts = filtered.slice(0, pageSize);
			component.set('v.displayContacts', displayContacts);
			component.set('v.currentPage', 1);

			clearItem.set('v.disabled', true);
			helper.removeActiveFilter(btn);
			if (Object.keys(filter).length === 0) {
				component.set('v.disableClearAll', true);
			}
		} else {
			if (menuItems.length) {
				const menuItem = menuItems.find(function(menuItem) {
					return menuItem.get('v.value') === selectedMenuItemValue;
				});
				menuItems.forEach(function(menuItem) {
					menuItem.set('v.checked', false);
				});
				menuItem.set('v.checked', !menuItem.get('v.checked'));
			} else {
				menuItems.set('v.checked', !menuItems.get('v.checked'));
			}

			const moreFilters = {
				[field]: selectedMenuItemValue
			};
			Object.assign(filter, moreFilters);
			component.set('v.filter', filter);
			const filtered = helper.filter(component, sortedContacts, filter)
				.sort(function(u1, u2) {
					return helper.sortByField(u1, u2, sortBy, sortDir, helper);
				})
			component.set('v.filteredContacts', filtered);

			// Handle page size
			helper.createPagination(component, helper, filtered.length);
			const displayContacts = filtered.slice(0, pageSize);
			component.set('v.displayContacts', displayContacts);
			component.set('v.currentPage', 1);

			clearItem.set('v.disabled', false);
			component.set('v.disableClearAll', false);
			helper.addActiveFilter(btn);
		}
	},
	handleClearAllFilters: function(component, event, helper) {
		const contacts = component.get('v.contacts');
		const filter = component.get('v.filter');
		const sortBy = component.get('v.sortBy');
		const sortDir = component.get('v.sortDir');
		const pageSize = component.get('v.pageSize');
		const fields = ['Name', 'Role', 'Consortium', 'State', 'CTU'];
		fields.forEach(function(field) {
			const menuItems = component.find(`${field}Items`);
			const clearItem = component.find(`clear${field}`);
			const btn = component.find(`${field}-filter`);
			if (menuItems) {
				if (menuItems.length) {
					menuItems.forEach(function(menuItem) {
						menuItem.set('v.checked', false);
					});
				} else {
					menuItems.set('v.checked', false);
				}
			}
			delete filter[field];
			if (clearItem) {
				clearItem.set('v.disabled', true);
			}
			if (btn) {
				helper.removeActiveFilter(btn);
			}
		});
		component.set('v.filter', {});
		component.set('v.disableClearAll', true);
		const filtered = helper.filter(component, contacts, filter)
			.sort(function(u1, u2) {
				return helper.sortByField(u1, u2, sortBy, sortDir, helper);
			});
		component.set('v.filteredContacts', filtered);

		// Handle page size
		helper.createPagination(component, helper, filtered.length);
		const displayContacts = filtered.slice(0, pageSize);
		component.set('v.displayContacts', displayContacts);
		component.set('v.currentPage', 1);
		component.set('v.searchText', '');
	},
	handlePrevClick: function(component, event, helper) {
		const currentPage = component.get('v.currentPage');
		if (currentPage > 1) {
			component.set('v.currentPage', currentPage - 1);

			// Handle pagination
			const displayContacts = helper.handlePagination(component);
			component.set('v.displayContacts', displayContacts);

			const scrollEl = document.getElementById('directory-table');
			scrollEl.scrollIntoView({behavior: 'smooth', block: 'start'});
		}
	},
	handlePaginationClick: function(component, event, helper) {
		const clickedNum = Number(event.getSource().get('v.name'));
		component.set('v.currentPage', clickedNum);

		// Handle pagination
		const displayContacts = helper.handlePagination(component);
		component.set('v.displayContacts', displayContacts);

		const scrollEl = document.getElementById('directory-table');
		scrollEl.scrollIntoView({behavior: 'smooth', block: 'start'});
	},
	handleNextClick: function(component, event, helper) {
		const currentPage = component.get('v.currentPage');
		const pages = component.get('v.pages');
		if (currentPage < pages.length) {
			component.set('v.currentPage', currentPage + 1);

			// Handle pagination
			const displayContacts = helper.handlePagination(component);
			component.set('v.displayContacts', displayContacts);

			const scrollEl = document.getElementById('directory-table');
			scrollEl.scrollIntoView({behavior: 'smooth', block: 'start'});
		}
	},
	handleSearch: function(component, event, helper) {
    helper.doSearch(component, helper);
	},
	handleKeyUp: function(component, event, helper) {
    const keyCode = event.getParams().keyCode;
    if (keyCode === 13) {
      helper.doSearch(component, helper);
    }
	},
	handleRowClick: function(component, event, helper) {
		const link = event.target.dataset.href;
		if (link) {
			window.location = link;
		}
	}
})