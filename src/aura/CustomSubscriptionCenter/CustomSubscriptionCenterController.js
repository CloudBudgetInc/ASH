({
	init: function(component, event, helper) {
		component.set("v.submittedAll", false);
		component.set("v.submitted", false);
		component.set("v.emailUpdated", false);
		helper
		.fetchUser(component)
		.then(function (user) {
			if (user) {
				component.set("v.isMember", user.ASH_Member__c);
			}
		})
		.catch(function (error) {
			console.error(error);
		});
		helper
		.fetchSubscriptions(component)
		.then(function (contact) {
			if (contact) {
				component.set("v.contact", contact);
			}
		})
		.catch(function (error) {
			console.error(error);
		});
	},
	handleAll: function(component, event, helper) {
		event.preventDefault();
		const subscribe = document.getElementById('subscribe').checked;
		helper
		.subscribeAll(component, subscribe)
		.then(function (contact) {
			if (contact) {
				component.set("v.contact", contact);
				component.set("v.submittedAll", true);
			}
		})
		.catch(function (error) {
			console.error(error);
		});
	},
	handleUpdate: function(component, event, helper) {
		event.preventDefault();
		// when user submits, the thank you confirmation message shows based on submitted aura attribute value.
		// however, it's not helpful when user makes a subsequent update after the initial since message just stays - so set to false to hide.
		component.set("v.submitted", false);

		const isMember = component.get('v.isMember');

		let theHematologist = true;
		let ashNewslink = true;
		const ashAnnualMeeting = document.getElementById('ashAnnualMeeting').checked;
		const ashMeetingOnLymphomiaBiology = document.getElementById('ashMeetingOnLymphomiaBiology').checked;
		const ashConsultativeHematologyCourse = document.getElementById('ashConsultativeHematologyCourse').checked;
		const latestInPrecisionMedicineAndImmunotherapy = document.getElementById('latestInPrecisionMedicineAndImmunotherapy').checked;
		const ashMeetingOnHematologicMalignancies = document.getElementById('ashMeetingOnHematologicMalignancies').checked;
		const highlightsOfAsh = document.getElementById('highlightsOfAsh').checked;
		const acuteMyeloidLeukemia = document.getElementById('acuteMyeloidLeukemia').checked;
		const immuneThrombocytopenia = document.getElementById('immuneThrombocytopenia').checked;
		const sickleCellDisease = document.getElementById('sickleCellDisease').checked;
		const venousThromboembolism = document.getElementById('venousThromboembolism').checked;
		const vonWillebrandDisease = document.getElementById('vonWillebrandDisease').checked;
		const honorificAndMentor = document.getElementById('honorificAndMentor').checked;
		const medicalStudents = document.getElementById('medicalStudents').checked;
		const careerAndTraining = document.getElementById('careerAndTraining').checked;
		const webinarsWebcastsPodcasts = document.getElementById('webinarsWebcastsPodcasts').checked;
		const jobCenterOpportunities = document.getElementById('jobCenterOpportunities').checked;
		const advanceNotice = document.getElementById('advanceNotice').checked;
		const bloodAdvancesHighlights = document.getElementById('bloodAdvancesHighlights').checked;
		const ashClinicalTrials = document.getElementById('ashClinicalTrials').checked;
		if (isMember) {
			theHematologist = document.getElementById('theHematologist').checked;
			ashNewslink = document.getElementById('ashNewslink').checked;
		}
		const thisWeekInBlood = document.getElementById('thisWeekInBlood').checked;
		const ashPracticeUpdate = document.getElementById('ashPracticeUpdate').checked;
		const traineENews = document.getElementById('traineENews').checked;
		const fdaAlerts = document.getElementById('fdaAlerts').checked;

		const updatedContact = {
			ASH_Annual_Meeting__c: !ashAnnualMeeting,
			ASH_Meeting_on_Lymphoma_Biology__c: !ashMeetingOnLymphomiaBiology,
			ASH_Consultative_Hematology_Course__c: !ashConsultativeHematologyCourse,
			Latest_in_Precision_Medicine_and_Immuno__c: !latestInPrecisionMedicineAndImmunotherapy,
			ASH_Meeting_on_Hematologic_Malignancies__c: !ashMeetingOnHematologicMalignancies,
			Highlights_of_ASH__c: !highlightsOfAsh,
			Acute_Myeloid_Leukemia__c: !acuteMyeloidLeukemia,
			Immune_Thrombocytopenia__c: !immuneThrombocytopenia,
			Sickle_Cell_Disease__c: !sickleCellDisease,
			Venous_Thromboembolism__c: !venousThromboembolism,
			Von_Willebrand_Disease__c: !vonWillebrandDisease,
			Honorific_and_Mentor__c: !honorificAndMentor,
			Medical_Students__c: !medicalStudents,
			Career_and_Training__c: !careerAndTraining,
			Webinars_Webcasts_Podcasts__c: !webinarsWebcastsPodcasts,
			Job_Center_Opportunities__c: !jobCenterOpportunities,
			Advance_Notice__c: !advanceNotice,
			Blood_Advances_Highlights__c: !bloodAdvancesHighlights,
			ASH_Clinical_Trials__c: !ashClinicalTrials,
			The_Hematologist__c: !theHematologist,
			ASH_Newslink__c: !ashNewslink,
			This_Week_in_Blood__c: !thisWeekInBlood,
			ASH_Practice_Update__c: !ashPracticeUpdate,
			TraineE_News__c: !traineENews,
			FDA_Alerts__c: !fdaAlerts
		}

		helper
		.updateSubscriptions(component, updatedContact)
		.then(function (contact) {
			if (contact) {
				component.set("v.contact", contact);
				component.set("v.submitted", true);
			}
		})
		.catch(function (error) {
			console.error(error);
		});
	},
	handleEmailUpdate: function(component, event, helper) {
		component.set("v.emailUpdated", true);
	},
	handleEmailChange: function(component, event, helper) {
		component.set("v.emailUpdated", false);
	},
})