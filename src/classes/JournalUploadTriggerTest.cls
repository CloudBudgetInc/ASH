@isTest(SeeAllData=true)
public class JournalUploadTriggerTest {

    static testMethod void testJournalUpload() {    
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
		Journal_Upload__c testUpload = new Journal_Upload__c();
        testUpload.Accounting_Company__c = provider.getCompany('ASH');
        testUpload.Journal_Date__c = Date.newInstance(2023,02,01);
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202308');
        testUpload.Period__c = somePeriod.Id;
        insert testUpload;
        
        Attachment att = new Attachment(Name='test-journal.csv');
        String header = 'JER,Sesame Street,2/28/2023,Miscellaneous,,,,,,J-10A,Junior Accountant Workflow,System GL Calendar,July 2021,667754.85,2/9/2023,Y,N\n';
        String line1 = 'JEI,211645.51,D,,Bond /Treasury Invst-Vanguard,ASH,,,,1165-100-000-000-00,,,,,          ,,\n';
        String line2 = 'JEI,211645.51,D,,Bond /Treasury Invst-Vanguard,ASH,,,,1165-100-000-000-00,,,,,          ,,\n'; 
		String combinedJournal = header + line1 + line2;    
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        contentVersion.PathOnClient = 'someJournal.txt'; // The files name, extension is very important here which will help the file in preview.
        contentVersion.Title = 'Some Test Journal'; // Display name of the files
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
        
        c2g__codaJournal__c thisJournal = [SELECT Id FROM c2g__codaJournal__c 
        	WHERE c2g__JournalDescription__c = 'Sesame Street'];
        System.assertNotEquals(null, thisJournal);
    }
}