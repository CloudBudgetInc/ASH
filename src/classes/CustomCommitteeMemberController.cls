public with sharing class CustomCommitteeMemberController {
  	@AuraEnabled(cacheable=true)
	public static List<Attribute__c> getCommitteeMembers(Id id) {
		List<Attribute__c> committees = [
			SELECT Address__c,Category__c,Comments__c,Committee_Name__c,Committee__c,
			Contact_Name__c,Contact__c,End__c,Id,Personify_id__c,Other_Value__c,
			Personify_Sub_Customer_id__c,Start__c,Status__c,Sub_Category__c,
			Contact__r.Id,Contact__r.Display_Name__c,Contact__r.Email,Contact__r.Phone,
			Contact__r.Fax,Contact__r.MailingStreet,Contact__r.MailingCity,
			Contact__r.MailingState,Contact__r.MailingPostalCode,Contact__r.MailingCountry,
			Sub_Contact__c,Sub_Account__c,Sub_Contact__r.Display_Name__c,Sub_Account__r.Name, Value__c
			FROM Attribute__c WHERE Category__c = 'Committee' AND Committee__c =: id
			ORDER BY Start__c DESC, Contact_Last_Name__c ASC
		];

		if (committees.isEmpty()) {
			return null;
		}

		return committees;
	}

	@AuraEnabled(cacheable=true)
	public static List<Attribute__c> getAssistant(Id id) {
		List<Attribute__c> attr = [
			SELECT Sub_Category__c, Value__c
			FROM Attribute__c 
			WHERE Sub_Category__c = 'ASSISTANT' AND Contact__r.Id =: id
			LIMIT 1
		];

		if (attr.isEmpty()) {
			return null;
		}

		return attr;
	}

	@AuraEnabled(cacheable=true)
	public static Boolean verifyHasEditPermissions() {
		String currentUserID = UserInfo.getUserId();
		String permissionSet = 'Committee_Comments_Executive_Staff';

		if (String.isBlank(currentUserID)) {
			return false;
		}

		List<PermissionSetAssignment> permissionList = [
			SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId 
			FROM PermissionSetAssignment 
			WHERE PermissionSet.Name =: permissionSet AND AssigneeId =: currentUserID
		];

		return !permissionList.isEmpty();
	}

	@AuraEnabled(cacheable=false)
	public static void addComment(Id attributeId, String comment) {
		List<Attribute__c> attrs = [
			SELECT Category__c,Comments__c,Contact__r.id
			FROM Attribute__c 
			WHERE Category__c = 'Committee' 
			AND Attribute__c.Id =: attributeId
		];

		Attribute__c attr = attrs.get(0);
		attr.Comments__c = comment;

		update attr;
	}

	@AuraEnabled(cacheable=true)
	public static List<EmailTemplate> getEmailTemplates() {
		List<EmailTemplate> templates = [
			SELECT Id,HtmlValue,Subject,Name FROM EmailTemplate
		];

		return templates;
	}

	@AuraEnabled(cacheable=true)
	public static List<OrgWideEmailAddress> getOrgEmailAddress() {
		List<OrgWideEmailAddress> addresses = [
			SELECT Address,DisplayName,Id FROM OrgWideEmailAddress
		];

		return addresses;
	}

	@AuraEnabled 
	public static String sendEmail(
		List<Id> contactIds,
		String mBody,
		String mSubject,
		Id templateId,
		Id orgWideAddressId
	) {
		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
		for (Id contactId : contactIds) {
			Contact contact = [SELECT Id,Display_Name__c,Name FROM Contact WHERE Id =: contactId];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setOrgWideEmailAddressId(orgWideAddressId);
			mail.setSubject(mSubject);
			
			String htmlReplace = mBody;
			if (contact.Id != null && htmlReplace != null
				&& htmlReplace.containsIgnoreCase('{{{Contact.Name}}}')) {
				htmlReplace = htmlReplace.replace('{{{Contact.Name}}}', contact.Display_Name__c); 
			}
	
			mail.setHtmlBody(htmlReplace);
			if (contact.Id != null) {
				mail.setTargetObjectId(contact.Id);
			}
			mail.setTreatTargetObjectAsRecipient(true);
			mail.setTreatBodiesAsTemplate(true);
			mail.setTemplateId(templateId);
			mails.add(mail);
		}

		List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails, false);
		if (results[0].success) {
			return 'The email was sent successfully.';
		}
		return 'The email failed to send: ' + results[0].errors[0].message;
	}
}