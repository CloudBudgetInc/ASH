({
  fetchContactId: function(component) {
		const action = component.get("c.getContactId");

		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
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
	fetchContentVersions: function(component) {
		const action = component.get("c.getContentVersions");

		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
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
	fetchContentDocuments: function(component) {
		const action = component.get("c.getContentDocuments");

		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
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
	loadData: function(component, helper) {
		helper.fetchContentDocuments(component)
		.then(function(docs) {
			helper.fetchContentVersions(component)
			.then(function(versions) {
				if (docs) {
					helper.sortByDate(docs).forEach(function (doc) {
						const [version] = versions.filter(function (ver) {
							return ver.ContentDocumentId === doc.Id;
						});
						if (version.Type__c) {
							doc.CardDescription = `${doc.Title} (${version.Type__c})`;
						} else {
							doc.CardDescription = doc.Title;
						}
					});
					component.set("v.files", docs);
				}
			}).catch(function(error) {
				console.error(error)
			});
		})
		.catch(function(error) {
			console.error(error)
		});
	},
	loadNewDocData: function(component, helper, contentDocId) {
		helper.fetchContentVersions(component)
		.then(function(versions) {
			const [version] = versions.filter(function (ver) {
				return ver.ContentDocumentId === contentDocId;
			});
			component.set("v.editVersionId", version.Id);
			component.set("v.editContentDocumentId", contentDocId);
			component.set("v.isModalOpen", true);
		}).catch(function(error) {
			console.error(error)
		});
	},
	addListeners: function(component, helper) {
		var elem = document.body;
    var lastClassName = elem.className;
    window.setInterval( function() {   
			var className = elem.className;
			if (className !== lastClassName) {
				if (className.indexOf('siteforce-Modal-Open') === -1) {
					helper.loadData(component, helper);
				}
				lastClassName = className;
			}
    },10);
	},
	sortByDate: function(documents) {
		return documents.sort(function(doc1, doc2){
			return new Date(doc2.LastModifiedDate) - new Date(doc1.LastModifiedDate);
		});
	}
})