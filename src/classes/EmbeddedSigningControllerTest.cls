@IsTest
private class EmbeddedSigningControllerTest{
    @IsTest
    static void testSendEnvelope(){
        // Mock the DocuSign eSignature API
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
                
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        System.runAs(dfsle.UserMock.createDocuSignAdministrator()) {
        
        //Get Account Record Type ID
        Id orgRecordType = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();

        // Create test data
        	String docusignId;
            Account myAccount = new Account(Name = 'Test Account');
            myAccount.recordtypeid = orgRecordType;
            insert myAccount;
                    
            Contact myContact = new Contact(
                AccountId = myAccount.Id,
                FirstName = 'Test',
                LastName = 'Contact',
                Phone = '555-123-5678',
                Email = 'test.ashcontact@example.com');
            insert myContact;

            dfsle.Tab.MergeField myCredentialsMerge = new dfsle.Tab.MergeField(
                'Contact.Credentials__c',
                null,
                null,
                false,
                false
            );
            System.assertNotEquals(null, myCredentialsMerge);
    
            dfsle.Tab myCredentialsTab = new dfsle.TextTab()
            .withMergeField(myCredentialsMerge)
            .withReadOnly(true)
            .withFormatting(new dfsle.Tab.Formatting(
                'Arial', // Font
                'default', // Font color
                12, // 14pt size,
                false, // Bold
                false, // Italic
                false, // Underline
                false, // Conceal value
                false)) // Fixed width
            .withPosition(new dfsle.Tab.Position(
                1,
                2,
                264,
                462,
                null,
                null));
                System.assertNotEquals(null, myCredentialsTab);
    
                // Create a Date Signed tab
            dfsle.Tab myDateSignedTab = new dfsle.DateSignedTab()
            .withFormatting(new dfsle.Tab.Formatting(
                'Arial', // Font
                'default', // Font color
                12, // 14pt size,
                false, // Bold
                false, // Italic
                false, // Underline
                false, // Conceal value
                false)) // Fixed width
            .withPosition(new dfsle.Tab.Position(
                1, // The document to use
                2, // Page number on the document
                360, // X position
                552, // Y position
                null, // Default width
                null)); // Default height
                System.assertNotEquals(null, myDateSignedTab);
    
            // Create a Name tab
            dfsle.Tab myFullNameTab = new dfsle.FullNameTab()
            .withFormatting(new dfsle.Tab.Formatting(
                'Arial', // Font
                'default', // Font color
                12, // 14pt size,
                false, // Bold
                false, // Italic
                false, // Underline
                false, // Conceal value
                false)) // Fixed width
            .withPosition(new dfsle.Tab.Position(
                1, // The document to use
                2, // Page number on the document
                265, // X position
                425, // Y position
                null, // Default width
                null)); // Default height
                System.assertNotEquals(null, myFullNameTab);
    
            //Create a Sign Here tab
            dfsle.Tab SignHereTab = new dfsle.SignHereTab()
                .withScale(1.5)
                .withRequired(true)
                .withAnchor(new dfsle.Tab.Anchor(
                    'signed',
                    false,
                    false,
                    'left',
                    true,
                    true,
                    'pixels',
                    0,
                    0
                ));
                System.assertNotEquals(null, SignHereTab);
                
                    // Create a test envelope with one document and one recipient
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(myAccount.Id))
                .withDocuments(new List<dfsle.Document> { 
                    dfsle.Document.fromTemplate(
                        dfsle.UUID.randomUUID(),
                        'test template')
                })
                .withRecipients(new List<dfsle.Recipient> {
                    dfsle.Recipient.fromSource(
                        myContact.FirstName + ' ' + myContact.LastName,
                        myContact.Email,
                        myContact.Phone,
                        'Signer 1',
                        new dfsle.Entity(myContact.Id))
                });
                System.assertNotEquals(null, myEnvelope);
            // Perform the test
            Test.startTest();
            docusignId = EmbeddedSigningController.sendEnvelope('e4113702-bf54-4877-859e-596ad4b039cb', 'Testing', myContact.id);
            //dfsle.Envelope myResult = dfsle.EnvelopeService.sendEnvelope(myEnvelope, true);
            Test.stopTest();
                    
            // Verify the results
            System.assertNotEquals(null, docusignId);
            }
    }
    
    @IsTest
    static void testgetEmbeddedSigningUrl(){
        // Mock the DocuSign eSignature API
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        System.runAs(dfsle.UserMock.createDocuSignAdministrator()){
        String envelopeID = String.valueOf(dfsle.UUID.randomUUID());
            Test.startTest();
        String testURL = EmbeddedSigningController.getEmbeddedSigningUrl(envelopeID,'http://www.test.org');
			Test.stopTest();
        System.assertNotEquals(null, testURL);
        }
    }
}