({
	init: function (component, event, helper) {
		helper
			.fetchAffiliations(component)
			.then(function (affiliations) {
				if (affiliations) {
					component.set("v.affiliations", helper.sortAffiliations(affiliations));
				} else {
					component.set("v.affiliations", []);
				}
			})
			.catch(function (error) {
				console.error(error);
			});
		helper
			.fetchContactId(component)
			.then(function (contactId) {
				component.set("v.contactId", contactId);
			})
			.catch(function (error) {
				console.error(error);
			});
	},
	openModal: function (component, event, helper) {
		const id = event.getSource().get("v.name");
		const affiliations = component.get("v.affiliations");
		component.set("v.isModalOpen", true);
		component.set("v.loading", true);
		component.set("v.editId", id);

		const [affiliation] = helper
			.sortAffiliations(affiliations)
			.filter(function (aff) {
				return aff.Id === id;
			});

		if (affiliation) {
			component.set("v.disableEndDate", affiliation.Active__c);
		}
	},
	closeModal: function (component, event, helper) {
		component.set("v.isModalOpen", false);
		component.set("v.loading", false);

		helper
			.fetchAffiliations(component)
			.then(function (affiliations) {
				component.set("v.affiliations", helper.sortAffiliations(affiliations));
			})
			.catch(function (error) {
				console.error(error);
			});
	},
	setLoadingFalse: function (component, event, helper) {
		component.set("v.loading", false);
	},
	submitAddDetails: function(component, event, helper) {
		event.preventDefault(); // stop form submission
		component.set("v.loading", true);
		const eventFields = event.getParam("fields");
		const newStaff = component.get('v.newOrg');
		if (newStaff) {
			component.find('staffAddForm').submit(eventFields);
		} else {
			component.set('v.showRequiredMsg', true);
			component.set("v.loading", false);
		}
	},
	submitDetails: function (component, event, helper) {
		component.set("v.loading", true);
	},
	openAddModal: function (component, event, helper) {
		component.set("v.isAddModalOpen", true);
		component.set('v.showRequiredMsg', false);
		component.set("v.loading", true);
	},
	closeAddModal: function (component, event, helper) {
		component.set("v.isAddModalOpen", false);
		component.set('v.showRequiredMsg', false);
		component.set("v.loading", false);
	},
	handleAddSuccess: function (component, event, helper) {
		component.set("v.isAddModalOpen", false);
		component.set("v.loading", false);
		component.set("v.isAddConfirmationModalOpen", true);
		component.set('v.showRequiredMsg', false);
		helper
			.fetchAffiliations(component)
			.then(function (affiliations) {
				component.set("v.affiliations", helper.sortAffiliations(affiliations));
			})
			.catch(function (error) {
				console.error(error);
			});
	},
	closeAddConfirmationModal: function (component, event, helper) {
    component.set("v.isAddConfirmationModalOpen", false);
    component.set("v.newOrg", '');
  },
	disableFields: function (component, event, helper) {
		const active = event.getParam('checked');
		component.set("v.disableEndDate", active);
		component.find("endDate").set("v.value", "");
	},
	openOrgModal: function(component, event, helper) {
		component.set("v.isOrgModalOpen", true);
		component.set('v.showRequiredMsg', false);
    component.set("v.isAddModalOpen", false);
    component.set("v.loading", true);
  },
  closeOrgModal: function(component, event, helper) {
    component.set("v.isOrgModalOpen", false);
    component.set("v.loading", false);
    component.set("v.isAddModalOpen", true);
  },
	handleOrgSuccess: function(component, event, helper) {
    const record = event.getParam("response");
    const id = record.id;
    helper.fetchPendingOrg(component, id)
    .then(function (res) {
      component.set("v.isOrgModalOpen", false);
      component.set("v.loading", false);
      component.set("v.newOrg", res);
      component.set("v.isAddModalOpen", true);
    })
    .catch(function (error) {
      console.error(error);
    });
  }
});