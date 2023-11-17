({
  init: function (component, event, helper) {
    helper
      .fetchAffiliations(component)
      .then(function (affiliations) {
        component.set("v.affiliations", helper.sortAffiliations(affiliations));
      })
      .catch(function (error) {
        console.error(error);
      });
      helper
      .fetchUserId(component)
      .then(function (userId) {
        component.set("v.userId", userId);
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
  submitDetails: function (component, event, helper) {
    component.set("v.loading", true);
  },
  openAddModal: function (component, event, helper) {
    component.set("v.isAddModalOpen", true);
    component.set("v.loading", true);
  },
  closeAddModal: function (component, event, helper) {
    component.set("v.isAddModalOpen", false);
    component.set("v.loading", false);
    component.set("v.newOrg", '');
  },
  handleAddSuccess: function (component, event, helper) {
    component.set("v.isAddModalOpen", false);
    component.set("v.loading", false);
    component.set("v.isAddConfirmationModalOpen", true);
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
  openDeleteModal: function (component, event, helper) {
    const id = event.getSource().get("v.name");
    component.set("v.isDeleteModalOpen", true);
    component.set("v.deleteId", id);
  },
  closeDeleteModal: function (component, event, helper) {
    component.set("v.isDeleteModalOpen", false);

    helper
      .fetchAffiliations(component)
      .then(function (affiliations) {
        component.set("v.affiliations", helper.sortAffiliations(affiliations));
      })
      .catch(function (error) {
        console.error(error);
      });
  },
  handleDelete: function (component, event, helper) {
    const id = component.get("v.deleteId");
    helper.deleteAffiliation(component, id).then(function (deletedId) {
      component.set("v.loading", false);
      if (id === deletedId) {
        component.set("v.isDeleteModalOpen", false);
        helper
          .fetchAffiliations(component)
          .then(function (affiliations) {
            component.set(
              "v.affiliations",
              helper.sortAffiliations(affiliations)
            );
          })
          .catch(function (error) {
            console.error(error);
          });
      }
    });
  },
  deactivate: function (component, event, helper) {
    const id = event.getSource().get("v.name");

    component.set("v.isModalOpen", true);
    component.set("v.loading", true);
    component.set("v.editId", id);
    component.set("v.disableEndDate", false);
    component.find("active").set("v.value", false);
    component.set("v.isDeleteModalOpen", false);
  },
  disableFields: function (component, event, helper) {
    const active = component.find("active").get("v.value");
    component.find("endDate").set("v.value", "");
    component.set("v.disableEndDate", active);
  },
  openOrgModal: function(component, event, helper) {
    component.set("v.isOrgModalOpen", true);
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