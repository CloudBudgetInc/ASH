public class EmbeddedSigningController {

    @AuraEnabled
    public static String sendEnvelope(String template, String description, Id recordId) {
        recordId = UserInfo.getUserId();
       // System.debug('The record ID is ' + recordId);
        User c = [SELECT contactID From User WHERE Id = :recordId];
        Id mySourceId = c.ContactId; // The ID of the initiating Salesforce object
        // Create an empty envelope and add a Salesforce Document and embedded signer  recipient
        // The embedded signer will be the current user with sequence and routing order 1 and role "Signer 1" by default
 /*
        // Create the credentials tab
        dfsle.Tab.MergeField myCredentialsMerge = new dfsle.Tab.MergeField(
            'Contact.Credentials__c',
            null,
            null,
            false,
            false
        );

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
*/
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
            440, // Y position
            null, // Default width
            null)); // Default height

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
            375, // X position
            370, // Y position
            null, // Default width
            null)); // Default height

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
        // Create a new recipient
        dfsle.Recipient myRecipient = dfsle.Recipient.newEmbeddedSigner()
            .withTabs(new List<dfsle.Tab> { // Associate the tabs with this recipient
                myDateSignedTab, myFullNameTab, SignHereTab
            });

        dfsle.Envelope dsEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
            new dfsle.Entity(mySourceId)) // The initiating Salesforce entity--current SF user (salesperson)
            .withDocuments(new List<dfsle.Document> {
            dfsle.Document.fromTemplate(dfsle.UUID.parse(template), description)
            })
            .withRecipients(new List<dfsle.Recipient> { myRecipient});

        dsEnvelope.withEmail('ASH Volunteer Code of Conduct', 'Sign the ASH Volunteer Code of Conduct');

        dsEnvelope.withOptions(new dfsle.Envelope.Options(
            true,
            new dfsle.Document.WriteBack(
                mySourceId,
                dfsle.Document.WRITE_BACK_NAME_ENVELOPE_STATUS_PDF,
                true,
                false),
            new Map<String, Map<String, Object>>{
                dfsle.Envelope.STATUS_COMPLETED => new Map<String, Object>{
                    'Contact.vcoc_status__c' => 'Signed'
                }
            },
            new Map<String, Map<String, Object>>())
            );
     
        // Send the envelope.
        dsEnvelope = dfsle.EnvelopeService.sendEnvelope(
            dsEnvelope, // The envelope to send
            true // Send now?
        );
        // Return string value of DocuSign envelope ID
        return String.valueOf(dsEnvelope.docuSignId);
    }
    

    @AuraEnabled
    public static String getEmbeddedSigningUrl(String envId, String url) {
        Url mySigningUrl = dfsle.SigningService.getEmbeddedSigningUrl(
        dfsle.UUID.parse(envId), // envId value as a UUID
        new URL(url) // url value as a URL
        );
        // Return string value of url to controller
        return mySigningUrl.toExternalForm();
    }
    
}