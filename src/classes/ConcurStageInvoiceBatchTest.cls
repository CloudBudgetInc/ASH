@isTest(SeeAllData=true)
public class ConcurStageInvoiceBatchTest {

    static testMethod void testConcurProcessing() {
        
        Concur_Batch__c someBatch = new Concur_Batch__c(Processed__c = false, Type__c = 'Invoice');
        insert someBatch;
        Attachment att = new Attachment(Name='concur-batch.csv');
        String header = 'EXTRACT|1051|2021-09-07|119|773005.9700\n';
        String line = 'DETAIL|ZZZAAA|*ASH Invoice Policy (Limit)|1800ADMIN, LLC(1800)-231||231|2021-08-25|2021-09-24|4000.0000|4000.0000|2021-08-27|2021-08-27|||||||||||||2022|||ACH|ASH|112|359||000|00||||N||||||||EMP|Employee|Y|0.0000|0.0000|D7555E0A256C4814A0FA|2021-08-25|CLIENT||||||MSD|MSD|7020|4000.0000|4000.0000|DR|USD|840|US, Dollar|7020||||||||||||2022||||ASH|112|359|000|00|53207|||||CROJA001|carojas@brightkey.net|Christian||Rojas|carojas@brightkey.net|||||Staff|||||||||||||||||ASH|171|367|||Staff|EMP||||1|1|Monthly database maintenance and support (July 2021)|2563   |Consultants (7020)|1.0000|4000.0000|4000.0000||||||||||||||||||||||||||1800ADMIN, LLC|1800|1800|2E2825CFCBD543818A36|22522 Welborne Manor Square|||Ashburn|VA|20148|US||||ACH|||||||||||||||N||||||||||||||||||||||||||||||0.0000|0.0000||||||N|||||||||||||||||0.0000|0.0000|0.0000|||4000.0000|0.0000||4000.0000|';
		String combinedLine = header + line;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        contentVersion.PathOnClient = 'extract.txt'; // The files name, extension is very important here which will help the file in preview.
        contentVersion.Title = 'Sample Concur Extract'; // Display name of the files
        contentVersion.VersionData = Blob.valueOf(combinedLine);
        insert contentVersion;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = someBatch.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;        
        
        Test.startTest();
        ConcurStageInvoiceBatch csib = new ConcurStageInvoiceBatch(someBatch.Id);
        Id jobid = Database.executeBatch(csib, 5);
        Test.stopTest();
        
        Payment_Shuttle__c someShuttle = [SELECT Id FROM Payment_Shuttle__c WHERE Concur_Key__c = 'ZZZAAA'];
        System.assert(someShuttle != null);
        
    	Concur_Batch__c newBatch = [SELECT Id, Staged__c FROM Concur_Batch__c WHERE Id = :someBatch.Id];
        System.assert(true, newBatch.Staged__c);        
    }
}