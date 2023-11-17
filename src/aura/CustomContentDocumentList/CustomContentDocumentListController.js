({
	init: function(component, event, helper) {
		helper.fetchContactId(component)
		.then(function(id) {
			component.set("v.recordId", id);
		})
		.catch(function(error) {
			console.error(error)
		});
		helper.loadData(component, helper);
		helper.addListeners(component, helper);
	},
	handleUploadFinished: function (component, event, helper) {
		// Get the list of uploaded files
		const uploadedFiles = event.getParam("files");
		const file = uploadedFiles[0];
		helper.loadNewDocData(component, helper, file.documentId);
	},
	closeModal: function (component, event, helper) {
    component.set("v.isModalOpen", false);
		component.set("v.loading", false);
		helper.loadData(component, helper);
  },
  setLoadingFalse: function (component, event, helper) {
    component.set("v.loading", false);
  },
  submitDetails: function (component, event, helper) {
		component.set("v.loading", true);
  },
})