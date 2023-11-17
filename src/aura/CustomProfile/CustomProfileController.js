({
	init: function(component, event, helper) {
		const recordId = component.get('v.recordId');
		const recordType = component.get('v.recordType');
		helper.fetchUser(component)
    .then(function(user) {
			if (user) {
				component.set('v.loggedInUser', user);

				if (recordType === 'User') {
					component.set('v.editable', true);

					helper.fetchContactUser(component, recordId)
					.then(function(contactUser) {
						component.set('v.contactUser', helper.mappedContactUser(contactUser));

						helper.fetchProfileImage(component, contactUser.Id)
						.then(function(photo) {
							if (photo) {
								component.set('v.profileImg', photo.largePhotoUrl);
							}
						}).catch(function(err) {
							console.log(err);
						});
					}).catch(function(err) {
						console.log(err);
					});
				}

				// Fetch Contact Junction
				helper.fetchContactJunction(component, recordId, recordType)
				.then(function(contactJunction) {
					if (contactJunction) {
						component.set('v.contactJunction', contactJunction);
		
						if (contactJunction && recordType === 'Contact Junction') {
							const userId = contactJunction.Contact__r.ASHRC_User__c;
							const contactId = contactJunction.Contact__c;
							const ctuId = contactJunction.Clinical_Trial_Unit__c;
		
							// Fetch User from Contact
							helper.fetchContactUser(component, userId)
							.then(function(contactUser) {
								component.set('v.contactUser', helper.mappedContactUser(contactUser));
								
								// Set editable if logged in user is contact user
								component.set('v.editable', user.Id === contactUser.Id);

								helper.fetchProfileImage(component, contactUser.Id)
								.then(function(photo) {
									if (photo) {
										component.set('v.profileImg', photo.largePhotoUrl);
									}
								}).catch(function(err) {
									console.log(err);
								});
							}).catch(function(err) {
								console.log(err);
							});

							helper.fetchContactAddress(component, contactId, ctuId)
							.then(function(contactAddress) {
								component.set('v.contactAddress', contactAddress);
							}).catch(function(err) {
								console.log(err);
							});
						}
					}
				}).catch(function(err) {
					console.log(err);
				});
			}
    }).catch(function(err) {
      console.log(err);
		});

		// if (recordType === 'Contact Junction') {
		// 	helper.fetchCurrentContactJunctionId(component).then(function(cjId) {
		// 		if (cjId) {
		// 			component.set('v.cjId', cjId);
		// 		}
		// 	}).catch(function(err) {
		// 		console.log(err);
		// 	});
		// }
	},
	handleImageUpload: function(component, event, helper) {
		const id = event.target.id;
		var upload = document.getElementById(id);
		var file = upload.files[0];
		if (!file) return;
		const reader = new FileReader();
		reader.onloadend = function() {
			const dataURL = reader.result;
				component.set('v.profileImg', dataURL);
				helper.upload(component, file, dataURL.match(/,(.*)$/)[1])
				.then(function(photo) {
					console.log('Uploaded');
				}).catch(function(err) {
					console.log(err);
				});
		};
		reader.readAsDataURL(file);
	},
	handleEdit: function(component, event, helper) {
		component.set('v.editing', true);
	},
	handleCancel: function(component, event, helper) {
		component.set('v.editing', false);
	},
	handleError: function(component, event, helper) {
		component.set('v.loading', false);
	},
	setLoadingFalse: function(component, event, helper) {
		component.set('v.loading', false);
	},
	submitDetails: function(component, event, helper) {
		component.set('v.loading', true);
	},
	handleSuccess: function(component, event, helper) {
		const user = component.get('v.loggedInUser');
		component.set('v.loading', false);
		component.set('v.submitted', true);

		// Fetch User from Contact
		helper.fetchContactUser(component, user.Id)
		.then(function(contactUser) {
			component.set('v.contactUser', helper.mappedContactUser(contactUser));
		}).catch(function(err) {
			console.log(err);
		});
	},
	handleInputChange: function(component, event, helper) {
		const user = component.get('v.contactUser');

		const prefix = component.find('Prefix').get('v.value');
		const firstName = component.find('FirstName').get('v.value');
		const lastName = component.find('LastName').get('v.value');
		const credentials = component.find('Credentials').get('v.value');
		const senderEmail = component.find('SenderEmail').get('v.value');
		const title = component.find('Title').get('v.value');
		const phone = component.find('Phone').get('v.value');
		const aboutMe = component.find('AboutMe').get('v.value');

		if ((!user.Salutation__c && prefix !== null && prefix !== '')
			|| (!!user.Salutation__c && user.Salutation__c !== prefix)) {
			component.set('v.changed', true);
		} else if ((!user.FirstName && firstName !== '' && firstName !== null)
			|| (!!user.FirstName && user.FirstName !== firstName)) {
			component.set('v.changed', true);
		} else if (user.LastName !== lastName) {
			component.set('v.changed', true);
		} else if ((!user.Credentials__ && credentials !== '' && credentials !== null)
			|| (!!user.Credentials__ && user.Credentials__ !== credentials)) {
			component.set('v.changed', true);
		} else if ((!user.SenderEmail && senderEmail !== '' && senderEmail !== null)
			|| (!!user.SenderEmail && user.SenderEmail !== senderEmail)) {
			component.set('v.changed', true);
		} else if ((!user.Title && title !== '' && title !== null) || (!!user.Title && user.Title !== title)) {
			component.set('v.changed', true);
		} else if ((!user.Phone && phone !== '' && phone !== null) || (!!user && user.Phone !== phone)) {
			component.set('v.changed', true);
		} else if ((!user.AboutMe && aboutMe !== '' && aboutMe !== null)
			|| (!!user.AboutMe && user.AboutMe !== aboutMe)) {
			component.set('v.changed', true);
		} else {
			component.set('v.changed', false);
		}
	}
})