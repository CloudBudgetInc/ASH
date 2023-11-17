public class CustomLoginController {
    @AuraEnabled
    public static String doLogin(String username, String password, String startUrl) {
        try {
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static User fetchUser() {
     // query current user information  
      User oUser = [SELECT Id, FirstName, LastName FROM User WHERE Id =: userInfo.getUserId()];
      String userType = UserInfo.getUserType();
      return oUser;
    }

    @AuraEnabled(cacheable=true)
    public static Contact fetchContact() {
			User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
			if (user.ContactId == null) {
				return null;
			}
	
			Contact contact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id =: user.ContactId];

			return contact;
    }
    
    @AuraEnabled(cacheable=true) 
    public static Boolean isLoggedIn() {
        Boolean isLoggedIn = false;
        String userType = UserInfo.getUserType();
        if (userType != 'Guest') {
            isLoggedIn = true;
        }
        return isLoggedIn;
    }
}