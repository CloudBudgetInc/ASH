public inherited sharing class CustomUserProfilePhotoController {
  @AuraEnabled(cacheable=true)
	public static Contact getContact(Id contactId) {
		List<Contact> contacts = [SELECT Id, Display_Name__c, Title, Member_Since_Year__c,
			npsp__Primary_Affiliation__c, npsp__Primary_Affiliation__r.Name, Membership_Type_Formula__c, ASH_Member__c, Donor_Level__c, Main_Address_Company__c
			FROM Contact WHERE Id =: contactId
		];

		if (contacts.size() > 0) {
			return contacts.get(0);
		}
		return null;
	}

	@AuraEnabled(cacheable=true)
	public static User getUserByContactId(Id contactId) {
		List<User> users = [SELECT Id, FirstName, LastName, Title, ContactId FROM User WHERE ContactId =: contactId];

		if (users.size() > 0) {
			return users.get(0);
		}
		return null;
	}

	@AuraEnabled(cacheable=true)
  public static Boolean isCurrentUser(Id userId) {
    return UserInfo.getUserId() == userId;
  }

	@AuraEnabled(cacheable=false)
  public static ConnectApi.Photo getProfileImage(Id userId) {
		String communityId = Network.getNetworkId();
    ConnectApi.Photo profileImage = ConnectApi.UserProfiles.getPhoto(communityId, userId);
    return profileImage;
  }

	@AuraEnabled(cacheable=false)
  public static ConnectApi.Photo uploadProfileImage(String base64Data, String contentType, String fileName) {
		Blob blobImage = EncodingUtil.base64Decode(base64Data);
		String communityId = Network.getNetworkId();
    Id userId = UserInfo.getUserId();
    ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(blobImage, contentType, fileName);
    ConnectApi.Photo profileImage = ConnectApi.UserProfiles.setPhoto(communityId, userId, fileUpload);
    return profileImage;
  }

	@AuraEnabled(cacheable=false)
  public static Boolean deleteProfileImage() {
		String communityId = Network.getNetworkId();
    Id userId = UserInfo.getUserId();
    ConnectApi.UserProfiles.deletePhoto(communityId, userId);
    return true;
  }
}