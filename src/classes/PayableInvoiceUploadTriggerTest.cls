@isTest(SeeAllData=true)
public class PayableInvoiceUploadTriggerTest {    

    static testMethod void testInvoiceUpload() {    
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
		Payable_Invoice_Upload__c testUpload = new Payable_Invoice_Upload__c();
        testUpload.Accounting_Company__c = provider.getCompany('ASH');
        testUpload.Period__c = provider.getPreviousPeriod('ASH');
        insert testUpload;
        
        Attachment att = new Attachment(Name='test-invoice-upload.csv');
        String header = 'Company,Account ,Sub account,Amount ,Traveler Name';
        String line1 = '9400,250-380-000-00,238.60,FRANK/ANNABEL\n';
        String line2 = '5270,270-370-000-21,418.70,EVOYAN/LEVON\n';
		String combinedJournal = header + line1 + line2;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        contentVersion.PathOnClient = 'someInvoice.txt'; // The files name, extension is very important here which will help the file in preview.
        contentVersion.Title = 'Some Test Invoice'; // Display name of the files
        contentVersion.VersionData = Blob.valueOf(combinedJournal);
        insert contentVersion;       
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = testUpload.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;      
        
        Test.startTest();
        testUpload.Process_File__c = true;
        update testUpload;
        Test.stopTest();
        
        c2g__codaPurchaseInvoice__c thisInvoice = [SELECT Id FROM c2g__codaPurchaseInvoice__c  
        	WHERE c2g__InvoiceDescription__c LIKE 'GTA/American Express%' and CreatedDate = TODAY AND c2g__InvoiceStatus__c = 'In Progress'];
        System.assertNotEquals(thisInvoice, null);        
    }
}