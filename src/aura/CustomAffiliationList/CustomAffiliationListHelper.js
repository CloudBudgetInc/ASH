({
  fetchAffiliations: function (component) {
    const action = component.get("c.getAffiliations");

    return new Promise(function (resolve, reject) {
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
  },
  fetchUserId: function (component) {
    const action = component.get("c.getCurrentUserId");

    return new Promise(function (resolve, reject) {
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
  },
  fetchContactId: function (component) {
    const action = component.get("c.getContactId");

    return new Promise(function (resolve, reject) {
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
  },
  deleteAffiliation: function (component, id) {
    const action = component.get("c.deleteAffiliationById");
    component.set("v.loading", true);

    return new Promise(function (resolve, reject) {
      action.setParam("id", id);
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
  },
  fetchPendingOrg: function (component, id) {
    const action = component.get("c.getPendingOrg");

    return new Promise(function (resolve, reject) {
      action.setParam("id", id);
      action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else {
          reject(response.getError()[0]);
        }
      });
      $A.enqueueAction(action);
    });
  },
  sortAffiliations: function (affiliations) {
    affiliations.sort(function (aff1, aff2) {
      return aff1.Active__c === aff2.Active__c ? 0 : aff1.Active__c ? -1 : 1;
		});
		return affiliations;
  }
});