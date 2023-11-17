({
	fetchContentVersions: function(component) {
		const action = component.get('c.getContentVersions');

		action.setStorable();
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	fetchContentDistribution: function(component, id) {
		const action = component.get('c.getContentDistributionById');

		action.setStorable();
		return new Promise(function(resolve, reject) {
			action.setParam('id', id);
			action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	fetchContentDocs: function(component) {
		const folderId = component.get('v.folderId');
		const action = component.get('c.getContentDocumentsByLibrary');

		action.setStorable();
		return new Promise(function(resolve, reject) {
			action.setParam('libraryId', folderId);
			action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	loadData: function(component, helper) {
		helper.fetchContentVersions(component)
		.then(function(contentVersions) {
			if (contentVersions) {
				// Filter docs
				helper.fetchContentDocs(component)
				.then(function(contentDocs) {
					if (contentDocs && contentDocs.length > 0) {
						const ids = contentDocs.map(function(d) {return d.Id});
						const docs = contentVersions.filter(function(ver) {
							return ids.indexOf(ver.ContentDocumentId) !== -1;
						});
						docs.forEach(function(contentVersion) {
							// Add urls to docs
							helper.fetchContentDistribution(component, contentVersion.ContentDocumentId)
							.then(function(contentDistribution) {
								contentVersion.ContentDownloadUrl = contentDistribution.ContentDownloadUrl;
								contentVersion.DistributionPublicUrl = contentDistribution.DistributionPublicUrl;
		
								// Set docs
								component.set('v.docs', docs);
							}).catch(function(error) {
								console.error(error)
							});
						});
					}
				}).catch(function(error) {
					console.error(error)
				});
			}
		}).catch(function(error) {
			console.error(error)
		});
	}
})