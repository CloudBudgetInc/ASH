({
	fetchContacts: function(cmp) {
		const action = cmp.get("c.getContactJunction");
    action.setStorable();
		return new Promise(function(resolve, reject) {
				action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === "SUCCESS") {
					const contacts = action.getReturnValue();
					cmp.set('v.contacts', contacts);
					resolve(contacts);
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	resetFilteredContacts: function(cmp, contacts, pageSize) {
		const filteredContacts = contacts.slice(0, pageSize);
		cmp.set('v.filteredContacts', filteredContacts);
		cmp.set('v.currentPage', 1);
	},
	createFilters: function(cmp, contactList) {
		const names = contactList.map(function(contact) {
			return contact.Contact__r.Display_Name__c;
		}).filter(function(item, index, arr) {
			return item && arr.indexOf(item) === index;
		}).sort();
		cmp.set('v.names', names);
		const roles = contactList.map(function(contact) {
			return contact.Contact_Type__c;
		}).filter(function(item, index, arr) {
			return item && arr.indexOf(item) === index;
		}).sort();
		cmp.set('v.roles', roles);
		const consortiums = contactList.map(function(contact) {
			if (contact.Clinical_Trial_Unit__r && contact.Clinical_Trial_Unit__r.Consortium__r
				&& contact.Clinical_Trial_Unit__r.Consortium__r.Name) {
				return contact.Clinical_Trial_Unit__r.Consortium__r.Name;
			}
			return '';
		}).filter(function(item, index, arr) {
			return item && arr.indexOf(item) === index;
		}).sort();
		cmp.set('v.consortiums', consortiums);
		const states = contactList.map(function(contact) {
			if (contact.Address__r && contact.Address__r.State__c) {
				return contact.Address__r.State__c;
			}
			return '';
		}).filter(function(item, index, arr) {
			return item && arr.indexOf(item) === index;
		}).sort();
		cmp.set('v.states', states);
		const ctus = contactList.map(function(contact) {
			if (contact.Clinical_Trial_Unit__r && contact.Clinical_Trial_Unit__r.Name) {
				return contact.Clinical_Trial_Unit__r.Name;
			}
			return '';
		}).filter(function(item, index, arr) {
			return item && arr.indexOf(item) === index;
		}).sort();
		cmp.set('v.ctus', ctus);
	},
	getField: function(field, contact) {
		if (field == 'Name') {
			return contact.Contact__r.Display_Name__c;
		} else if (field == 'Role') {
			if (contact.Contact_Type__c) {
				return contact.Contact_Type__c;
			}
			return 'N/A';
		} else if (field == 'Consortium') {
			if (contact.Clinical_Trial_Unit__r && contact.Clinical_Trial_Unit__r.Consortium__r) {
				return contact.Clinical_Trial_Unit__r.Consortium__r.Name;
			}
			return 'N/A';
		} else if (field == 'State') {
			if (contact.Address__r && contact.Address__r.State__c) {
					return contact.Address__r.State__c;
			}
			return 'N/A';
		} else if (field == 'CTU') {
			if (contact.Clinical_Trial_Unit__r && contact.Clinical_Trial_Unit__r.Name) {
				return contact.Clinical_Trial_Unit__r.Name;
			}
			return 'N/A';
		}
	},
	filter: function(cmp, contacts, filter) {
		const filtered = contacts.filter(function(contact) {
			return Object.keys(this).every((key) => {
				if (key == 'Name') {
					let name = contact.Contact__r.Display_Name__c;
					return name === this[key];
				} else if (key == 'Role') {
					return contact.Contact_Type__c === this[key];
				} else if (key == 'Consortium') {
					if (contact.Clinical_Trial_Unit__r && contact.Clinical_Trial_Unit__r.Consortium__r) {
						return contact.Clinical_Trial_Unit__r.Consortium__r.Name === this[key];
					}
					return false;
				} else if (key == 'State') {
					if (contact.Address__r && contact.Address__r.State__c) {
						return contact.Address__r.State__c === this[key];
					}
					return false;
				} else if (key == 'CTU') {
					if (contact.Clinical_Trial_Unit__r && contact.Clinical_Trial_Unit__r.Name) {
						return contact.Clinical_Trial_Unit__r.Name === this[key];
					}
				}
			});
		}, filter);
		return filtered;
	},
	sortByField: function(u1, u2, sortField, sortDir, helper) {
		const contact1 = helper.getField(sortField, u1);
		const contact2 = helper.getField(sortField, u2);
		if (contact1 === contact2) {
      return 0;
    }
    // NULLS go last.
    if (contact1 === null) {
      return 1;
    }
    if (contact2 === null) {
      return -1;
    }
		// Sort by ascending price.
		if (sortDir === 'ASC') {
			return contact1 < contact2 ? -1 : 1;
		}
    return contact1 < contact2 ? 1 : -1;
	},
	addActiveFilter: function(cmp) {
		window.setTimeout(
			$A.getCallback(function() {
				if (!$A.util.hasClass(cmp, 'user-directory__filter-btn--active')) {
					$A.util.addClass(cmp, 'user-directory__filter-btn--active');
				}
		}), 200);
	},
	removeActiveFilter: function(cmp) {
		window.setTimeout(
			$A.getCallback(function() {
				if ($A.util.hasClass(cmp, 'user-directory__filter-btn--active')) {
					$A.util.removeClass(cmp, 'user-directory__filter-btn--active');
				}
		}), 200);
	},
	createPagination: function(cmp, helper, total) {
		const pageSize = cmp.get('v.pageSize');
		let numOfPages = Math.ceil(total / pageSize);
		const pages = [];
		// Create pagination list items
		for (let i = 1; i < numOfPages + 1; i++) {
			pages.push(Number(i));
		}
		cmp.set('v.pages', pages);
	},
	handlePagination: function(cmp) {
		const currentPage = cmp.get('v.currentPage');
		const pageSize = cmp.get('v.pageSize');
		const filteredContacts = cmp.get('v.filteredContacts');
		const startOffset = currentPage === 1 ? 0 : (currentPage - 1) * pageSize;
		const endOffset = currentPage * pageSize;
		return filteredContacts.slice(startOffset, endOffset);
	},
	filterSearch: function(contacts, txt) {
		const searchText = txt.toLowerCase();
		const filtered = contacts.filter(function(contact) {
			let role;
			let consortium;
			let state;
			let ctu;
			let name = contact.Contact__r.Display_Name__c.toLowerCase();
			if (!!contact.Contact_Type__c) {
				role = contact.Contact_Type__c;
			}
			if (contact.Clinical_Trial_Unit__r && contact.Clinical_Trial_Unit__r.Consortium__r) {
				consortium = contact.Clinical_Trial_Unit__r.Consortium__r.Name.toLowerCase();
			}
			if (contact.Address__r && contact.Address__r.State__c) {
				state = contact.Address__r.State__c.toLowerCase();
			}
			if (contact.Clinical_Trial_Unit__r && contact.Clinical_Trial_Unit__r.Name) {
				ctu = contact.Clinical_Trial_Unit__r.Name.toLowerCase();
			}

			return name.indexOf(searchText) !== -1 || (!!role && role.indexOf(searchText) !== -1)
				|| (!!consortium && consortium.indexOf(searchText) !== -1) || (!!state && state.indexOf(searchText) !== -1)
				|| (!!ctu && ctu.indexOf(searchText) !== -1);
		});
		return filtered;
	},
	doSearch: function(component, helper) {
		const contacts = component.get('v.contacts');
		const searchText = component.get('v.searchText');
		const pageSize = component.get('v.pageSize');
		const sortBy = component.get('v.sortBy');
		const sortDir = component.get('v.sortDir');

		const sortedContacts = contacts.sort(function(u1, u2) {
			return helper.sortByField(u1, u2, sortBy, sortDir, helper);
		});

    if (searchText) {
			const filtered = helper.filterSearch(sortedContacts, searchText)
				.sort(function(u1, u2) {
					return helper.sortByField(u1, u2, sortBy, sortDir, helper);
				});
			component.set('v.filteredContacts', filtered);
			
			// Handle page size
			helper.createPagination(component, helper, filtered.length);
			const displayContacts = filtered.slice(0, pageSize);
			component.set('v.displayContacts', displayContacts);
			component.set('v.currentPage', 1);
			component.set('v.disableClearAll', false);
    } else {
			component.set('v.filter', {});
			component.set('v.disableClearAll', true);
			const filtered = helper.filter(component, sortedContacts, {})
				.sort(function(u1, u2) {
					return helper.sortByField(u1, u2, sortBy, sortDir, helper);
				});
			component.set('v.filteredContacts', filtered);

			// Handle page size
			helper.createPagination(component, helper, filtered.length);
			const displayContacts = filtered.slice(0, pageSize);
			component.set('v.displayContacts', displayContacts);
			component.set('v.currentPage', 1);
		}
  }
})