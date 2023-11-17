public with sharing class CustomUserProfileController {
  @AuraEnabled(cacheable=true)
  public static user getCurrentUser() {
    User user = [SELECT Id, FullPhotoURL, MediumPhotoURL, SmallPhotoURL FROM User WHERE Id =: UserInfo.getUserId()];
    return user;
  }

  @AuraEnabled(cacheable=true)
  public static Contact_Junction__c getContactJunctionById(Id id) {
    return [SELECT Id, Clinical_Trial_Unit__r.Name, Clinical_Trial_Unit__r.Consortium__r.Name, 
      Clinical_Trial_Unit__c, Contact__c, Contact__r.Name, Contact__r.Title, Contact__r.Email,
      Contact__r.npe01__WorkPhone__c, Contact__r.Show_Email__c, Contact__r.Show_Phone__c,
      Contact_Type__c, Contact__r.ASHRC_User__c
      FROM Contact_Junction__c WHERE Id =: id];
  }

  @AuraEnabled(cacheable=true)
  public static Contact_Junction__c getContactJunctionByUser() {
    User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		if (user.ContactId == null) {
			return null;
    }

    List<Contact_Junction__c> cjs = [
      SELECT Id, Clinical_Trial_Unit__r.Name, Clinical_Trial_Unit__r.Consortium__r.Name, 
      Clinical_Trial_Unit__c, Contact__c, Contact__r.Name, Contact__r.Title, Contact__r.Email,
      Contact__r.npe01__WorkPhone__c, Contact__r.Show_Email__c, Contact__r.Show_Phone__c,
      Contact_Type__c, Contact__r.ASHRC_User__c
      FROM Contact_Junction__c WHERE Contact__r.ASHRC_User__c =: user.Id
    ];

    if (cjs.size() > 0) {
      return cjs[0];
    }

    return null;
  }

  @AuraEnabled(cacheable=false)
  public static User getUserById(Id id) {
    User user = [
      SELECT Id, FirstName, MiddleName, LastName, SenderEmail, Title, Phone, Show_Email__c, Show_Phone__c,
        Salutation__c, AboutMe, Credentials__c
      FROM User WHERE Id =: id];
    return user;
  }

  @AuraEnabled(cacheable=false)
  public static Contact_Junction__c getAddressByContactJunction(Id contactId, Id ctuId) {
    Contact_Junction__c[] contactAddress = [
      SELECT Id, Address__r.City__c, Address__r.State__c
      FROM Contact_Junction__c
      WHERE Contact__c =: contactId AND Clinical_Trial_Unit__c =: ctuId
    ];

    if (contactAddress.size() > 0) {
      return contactAddress[0];
    }

    return null;
  }

  @AuraEnabled(cacheable=false)
  public static ConnectApi.Photo getProfileImage(Id userId) {
    ConnectApi.Photo profileImage = ConnectApi.UserProfiles.getPhoto('0DB3u000000g0P4GAI', userId);

    if (profileImage != null) {
      return profileImage;
    }

    return null;
  }

  @AuraEnabled(cacheable=false)
  public static ConnectApi.Photo uploadProfileImage(String base64Data, String contentType, String fileName) {
    Blob blobImage = EncodingUtil.base64Decode(base64Data);
    ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(blobImage, contentType, fileName);
    Id userId = UserInfo.getUserId();
    ConnectApi.Photo profileImage = ConnectApi.UserProfiles.setPhoto('0DB3u000000g0P4GAI', userId, fileUpload);
    return profileImage;
  }
}