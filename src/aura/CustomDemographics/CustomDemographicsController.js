({
	init: function(component, event, helper) {
		helper.fetchContact(component)
		.then(function(contact) {
			if (contact) {
				component.set('v.contact', contact);
				component.set('v.optIn', helper.setDemographic(contact));
				component.set('v.currentOptIn', helper.setOptIn(contact));
				

				if (contact.Ethnicity__c) {
					const ethnicities = contact.Ethnicity__c.split(';');
					component.set('v.ethnicities', ethnicities);
				} else {
					component.set('v.ethnicities', []);
				}
				component.set(
					'v.showEthnicitySelf',
					contact.Ethnicity__c.indexOf('Prefer to Self-Identify') !== -1
				);
			}
		})
		.catch(function(){});
	},
	openModal: function(component, event, helper) {
		component.set('v.isModalOpen', true);
		component.set('v.loading', true);
		const contact = component.get('v.contact');
		component.set('v.selectedLookUpRecord', {});
		if (contact.COB__c) {
			component.set('v.selectedLookUpRecord', contact.COB__r);
		}
	},
	closeModal: function(component, event, helper) {
		component.set('v.isModalOpen', false);
		component.set('v.loading', false);
		helper.fetchContact(component).then(function(contact) {
			component.set('v.contact', contact);
			if (contact.Ethnicity__c) {
				const ethnicities = contact.Ethnicity__c.split(';');
				component.set('v.ethnicities', ethnicities);
			} else {
				component.set('v.ethnicities', []);
			}
			component.set(
				'v.showEthnicitySelf',
				contact.Ethnicity__c.indexOf('Prefer to Self-Identify') !== -1
			);
		})
		.catch(function(){});
	},
	handleError: function(component, event, helper) {
		component.set('v.loading', false);
	},
	setLoadingFalse: function(component, event, helper) {
		component.set('v.loading', false);
	},
	submitDetails: function(component, event, helper) {
		event.preventDefault(); // stop form submission
		component.set('v.loading', true);
		const eventFields = event.getParam('fields');
		if (component.get('v.selectedLookUpRecord').Id != undefined) {
			const countryId = component.get('v.selectedLookUpRecord').Id;
			eventFields['COB__c'] = countryId;
		} else {
			eventFields['COB__c'] = null;
		}
		component.find('deiEditForm').submit(eventFields);
	},
	handleOptIn: function(component, event, helper) {
		const value = event.getParam('value');
		const optIn = component.get('v.currentOptIn');
		if (optIn === 'Opt-In' && value === 'Opt-Out') {
			component.set('v.isConfirmModalOpen', true);
		} else {
			helper.optIn(component, value)
			.then(function(contact) {
				component.set('v.optIn', helper.setDemographic(contact));
				component.set('v.currentOptIn', helper.setOptIn(contact));
			})
			.catch(function(){});
		}
	},
	closeConfirmModal: function(component, event, helper) {
		component.set('v.isConfirmModalOpen', false);
		component.find('opt-in').set('v.value', 'Opt-In');
	},
	handleConfirm: function(component, event, helper) {
		component.set('v.loading', true);
		helper.optIn(component, 'Opt-Out')
			.then(function(contact) {
				component.set('v.optIn', helper.setDemographic(contact));
				component.set('v.currentOptIn', helper.setOptIn(contact));
				component.set('v.loading', false);
				component.set('v.isConfirmModalOpen', false);
			})
			.catch(function(err){
				console.log(err);
			});
		helper.fetchContact(component)
			.then(function(contact) {
				if (contact) {
					component.set('v.contact', contact);
					component.set('v.optIn', helper.setDemographic(contact));
					component.set('v.currentOptIn', helper.setOptIn(contact));
					if (contact.Ethnicity__c) {
						const ethnicities = contact.Ethnicity__c.split(';');
						component.set('v.ethnicities', ethnicities);
					} else {
						component.set('v.ethnicities', []);
					}
					if (contact.Ethnicity__c) {
						component.set(
							'v.showEthnicitySelf',
							contact.Ethnicity__c.indexOf('Prefer to Self-Identify') !== -1
						);
					}
				}
			})
			.catch(function(err){
				console.log(err);
			});
	},
	openEthnicityModal: function(component, event, helper) {
		component.set('v.isEthnicityModalOpen', true);
	},
	closeEthnicityModal: function(component, event, helper) {
		component.set('v.isEthnicityModalOpen', false);
	},
	handleGenderSelf: function (component, event, helper) {
    const genderVal = component.find('gender').get('v.value');
		const genderSelf = component.find('genderSelf');
		if (genderVal !== 'Prefer to Self-Describe') {
			$A.util.addClass(genderSelf, 'hide');
			genderSelf.set('v.required', null);
		} else {
			$A.util.removeClass(genderSelf, 'hide');
			genderSelf.set('v.required', true);
		}
	},
	handlePronounsSelf: function (component, event, helper) {
    const pronounsVal = component.find('pronouns').get('v.value');
		const pronounsSelf = component.find('pronounsSelf');
		if (pronounsVal !== 'Prefer to Self-Describe') {
			$A.util.addClass(pronounsSelf, 'hide');
			pronounsSelf.set('v.required', null);
		} else {
			$A.util.removeClass(pronounsSelf, 'hide');
			pronounsSelf.set('v.required', true);
		}
	},
	handleOrientationSelf: function (component, event, helper) {
    const orientationVal = component.find('orientation').get('v.value');
		const orientationSelf = component.find('orientationSelf');
		if (orientationVal !== 'Prefer to Self-Describe') {
			$A.util.addClass(orientationSelf, 'hide');
			orientationSelf.set('v.required', null);
		} else {
			$A.util.removeClass(orientationSelf, 'hide');
			orientationSelf.set('v.required', true);
		}
	},
	handleDisabilitySelf: function (component, event, helper) {
    const disabilityVal = component.find('disability').get('v.value');
		const disabilitySelf = component.find('disabilitySelf');
		if (disabilityVal !== 'Prefer to Self-Describe') {
			$A.util.addClass(disabilitySelf, 'hide');
			disabilitySelf.set('v.required', null);
		} else {
			$A.util.removeClass(disabilitySelf, 'hide');
			disabilitySelf.set('v.required', true);
		}
	},
	handleEthnicitySelf: function (component, event, helper) {
    const ethnicityVal = component.find('ethnicity').get('v.value');
		const ethnicitySelf = component.find('ethnicitySelf');
		if (ethnicityVal.indexOf('Prefer to Self-Identify') === -1) {
			$A.util.addClass(ethnicitySelf, 'hide');
			ethnicitySelf.set('v.required', null);
		} else {
			$A.util.removeClass(ethnicitySelf, 'hide');
			ethnicitySelf.set('v.required', true);
		}
	},
})