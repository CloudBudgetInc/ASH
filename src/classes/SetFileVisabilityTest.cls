@isTest
private class SetFileVisabilityTest {
static testMethod void insertDocument() 
    {
        
        //Create portal account owner
		UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
		User portalAccountOwner1 = new User(
        UserRoleId = portalRole.Id,
        ProfileId = profile1.Id,
        Username = 'ashadmin@ashtest.org',
        Alias = 'ashadmin',
        Email='ashadmin@ashtest.org',
        EmailEncodingKey='UTF-8',
        Firstname='Ash',
        Lastname='Admin',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/New_York');        
		Database.insert(portalAccountOwner1);

        System.runAs(portalAccountOwner1){       
        Account act = new Account(
		Name = 'Test Account',
        OwnerId = portalAccountOwner1.id);
		Database.insert(act);
        
        //Create test contact
        Contact cont = new Contact ();
        cont.FirstName = 'FirstName';
        cont.LastName = 'LastName';
        cont.Email='ashtestemail@ashtest.com';
        cont.AccountId = act.Id;
        insert cont;
          
        //Get record ID of portal profile
        Id portalProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User (okta)' LIMIT 1].Id;
        
        //Create portal user
        User testUser = new User ();
        testUser.FirstName = 'FirstName';
        testUser.LastName = 'LastName';
        testUser.Email = 'ashtestemail@ashtest.com';
        testUser.Username = 'ashtestemail@ashtest.com';
        testUser.Alias = 'ashtest';
        testUser.LocaleSidKey = 'en_US';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.TimeZoneSidKey = 'America/New_York';
        testuser.ProfileId = portalProfileId;
        
        testUser.contactid = cont.id;
        insert testUser;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'VCOC',
            PathOnClient = 'vcoc.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
       
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cont.id;
        cdl.ContentDocumentId = documents[0].Id;
        insert cdl;
        	}
        }
}