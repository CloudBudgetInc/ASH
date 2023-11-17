({
	init: function(component, event, helper) {
		helper.fetchAddresses(component)
		.then(function (addresses) {
			component.set("v.addresses", helper.sortAddresses(addresses));
		}).catch(function(error) {
			console.error(error);
		});
		helper.fetchContactId(component)
		.then(function (contactId) {
			component.set("v.contactId", contactId);
		}).catch(function(error) {
			console.error(error);
		});
		helper.checkMember(component)
		.then(function(isMember) {
			component.set("v.isMember", isMember);
		})
		.catch(function(){});
		// helper.fetchAccountId(component)
		// .then(function (accountId) {
		// 	component.set("v.accountId", accountId);
		// }).catch(function(error) {
		// 	console.error(error);
		// });
	},
	openModal: function(component, event, helper) {
		const id = event.getSource().get('v.name');
		component.set("v.isModalOpen", true);
		component.set("v.loading", true);
		component.set("v.editId", id);
		const addresses = component.get("v.addresses");
		const [editAddress] = addresses.filter(function(addr) {
			return addr.Id === id;
		});
		if (editAddress.Country_Lookup__c) {
			component.set("v.selectedLookUpRecord", editAddress.Country_Lookup__r);
			window.setTimeout(
				$A.getCallback(function() {
					document.getElementById('custom-lookup-input').value = editAddress.Country_Lookup__r.Name;
			}), 200);
		}
	},
	closeModal: function(component, event, helper) {
		component.set("v.isModalOpen", false);
		component.set("v.loading", false);

		helper.fetchAddresses(component).then(function(addresses) {
			component.set("v.addresses", helper.sortAddresses(addresses));
		})
		.catch(function(error) {
			console.error(error);
		});
	},
	setLoadingFalse: function(component, event, helper) {
		component.set("v.loading", false);
	},
	submitAddDetails: function(component, event, helper) {
		event.preventDefault(); // stop form submission
		component.set("v.loading", true);
		const eventFields = event.getParam("fields");
		if (component.get("v.selectedLookUpRecord").Id != undefined) {
			const countryId = component.get("v.selectedLookUpRecord").Id;
			eventFields["Country_Lookup__c"] = countryId;
		} else {
			eventFields["Country_Lookup__c"] = null;
		}
		component.find('addressAddForm').submit(eventFields);
	},
	submitEditDetails: function(component, event, helper) {
		event.preventDefault(); // stop form submission
		component.set("v.loading", true);
		const eventFields = event.getParam("fields");
		if(component.get("v.selectedLookUpRecord").Id != undefined) {
			const countryId = component.get("v.selectedLookUpRecord").Id;
			eventFields["Country_Lookup__c"] = countryId;
		} else {
			eventFields["Country_Lookup__c"] = null;
		}
		component.find('addressEditForm').submit(eventFields);
	},
	handleSuccess: function(component, event, helper) {
		component.set("v.isAddModalOpen", false);
		component.set("v.isModalOpen", false);
		component.set("v.loading", false);
		location.reload();
	},
	openAddModal: function(component, event, helper) {
		component.set("v.isAddModalOpen", true);
		component.set("v.loading", true);
	},
	closeAddModal: function(component, event, helper) {
		component.set("v.isAddModalOpen", false);
		component.set("v.loading", false);
		helper.fetchAddresses(component).then(function(addresses) {
			component.set("v.addresses", helper.sortAddresses(addresses));
		})
		.catch(function(error) {
			console.error(error);
		});
	},
	openRemoveModal: function(component, event, helper) {
		const id = event.getSource().get('v.name');
		component.set("v.isRemoveModalOpen", true);
		component.set("v.removeId", id);
	},
	closeRemoveModal: function(component, event, helper) {
		component.set("v.isRemoveModalOpen", false);

		helper.fetchAddresses(component).then(function(addresses) {
			component.set("v.addresses", helper.sortAddresses(addresses));
		})
		.catch(function(error) {
			console.error(error);
		});
	},
	handleRemove: function(component, event, helper) {
		const id = component.get('v.removeId');
		helper.removeAddress(component, id)
		.then(function(removeId) {
			component.set("v.loading", false);
			if (id === removeId) {
				component.set("v.isRemoveModalOpen", false);
				location.reload();
			}
		});
	},
})