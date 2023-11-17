public with sharing class CurrentUserController {
    @AuraEnabled 
    public static User updateLLSAuth() {
      User currentUser = [SELECT id FROM User Where id =: userInfo.getUserId()];
      currentUser.LLS_Authorized__c = true;
      update currentUser;
      return currentUser;
    }

    @AuraEnabled 
    public static User getCurrentUser() {
      User user = [SELECT Id, FirstName, LastName, Email, AboutMe, FullPhotoUrl, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
      return user;
    }

    @AuraEnabled 
    public static Contact getContact() {
      User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];

      Contact contact = [SELECT Id, Academic_Appointment__c,Credential__c,Display_Name__c,Fax,
      HomePhone,npe01__AlternateEmail__c,npe01__HomeEmail__c,npe01__PreferredPhone__c,npe01__Preferred_Email__c,
      npe01__WorkEmail__c,npe01__WorkPhone__c,MobilePhone,Primary_Institutional_Affiliation__c,Primary_Subspecialty__c,
      Primary_Subspecialty_Area__c,Specialty__c, Member_Directory__c,Effort_Administration__c,
      Effort_Other__c,Effort_Patient_Care__c,Effort_Research__c,Effort_Teaching__c, OtherPhone, About_Me__c,
      FirstName, LastName, Email, ASH_Member__c, Renewal__c, Current_Membership_Grace_Date__c, 
      Current_Membership_Start__c,Current_Membership_End__c, Membership_Status__c, Personify_ID__c
      FROM Contact WHERE Id =: user.ContactId];
      return contact;
    }

    @AuraEnabled
    public static Boolean checkMemberStatus() {
      User user = [SELECT Id, ASH_Member__c FROM User WHERE Id =: UserInfo.getUserId()];
      return user.ASH_Member__c;
    }

    @AuraEnabled 
    public static Contact updateMemberDirectory(Boolean memberDir) {
      User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];

      Contact contact = [SELECT Id, Member_Directory__c FROM Contact WHERE Id =: user.ContactId];

      contact.Member_Directory__c = memberDir;
      update contact;

      return contact;
    }

    @AuraEnabled 
    public static User getUserById(Id id) {
      User user = [SELECT Id, FirstName, LastName, FullPhotoUrl FROM User WHERE Id =: id];
      return user;
    }
}