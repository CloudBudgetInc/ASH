@isTest(SeeAllData=true)
public class ConcurStageExpenseBatchTest {

    static testMethod void testConcurProcessing() {
        
        Concur_Batch__c someBatch = new Concur_Batch__c(Processed__c = false, Type__c = 'Expense');
        insert someBatch;
        System.debug(someBatch);
        Attachment att = new Attachment(Name='concur-batch.csv');
        String header = 'EXTRACT|2021-09-20|14|1504.3600|582\n';
        String line = 'DETAIL|ZZZAAA|2021-09-20|1|ATSU99|Atsu|Rosina||Staff||ASH|171|367|||||49.9500|D301BCEA2AA74BF5821C|27892|MSD|USD|UNITED STATES|2021-09-08|2021-09-08|2021-09-20|PPE Reimbursement|Y|N|N|49.9500|49.9500|*ASH Staff Policy|||ASH|171|367||||||00|Staff||||Level 1|N|REIM||||Staff||||||203264|REG|9676 - Wellness Program|2021-08-07|USD|1.0000|M|N||||N|N|||||ASH|302|375|000|00|||||Staff||||Level 1|N|||||||||||||||||||||||||||||0.0000|49.9500|49.9500|49.9500|49.9500|CASH|Cash|||||||||||||||||||||||||||||||||HOME|||Company|Company/Employee Pseudo Payment Code|Employee|Company/Employee Pseudo Payment Code|9676|DR|+49.9500|2867889|||||||||||||||||||216874|100.0000|||||Staff|||||N|ASH|302|375|000|00||||||49.9500|||||||||||||||||||||||||||||||||||0.0000|49.9500|0.0000|49.9500|Employee Paid||||||||||Y||||ratsu@hematology.org|ratsu@hematology.org||367|000|00|Staff|||ASH|Level 1|N||||||||||||||||||||||||||||||||||||0.0000|49.9500|49.9500|0.0000|0.0000|0.0000|0.0000|0.0000|49.9500|0.0000||0.0000|49.9500||||0.0000||0.0000||||||N||||US||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||';
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
        Id batchId = someBatch.Id;
        System.debug(batchId);
        ConcurStageExpenseBatch cseb = new ConcurStageExpenseBatch(batchId);
        Id jobid = Database.executeBatch(cseb, 5);
        Test.stopTest();
        
        Payment_Shuttle__c someShuttle = [SELECT Id FROM Payment_Shuttle__c WHERE Vendor_ID__c = 'ATSU99'];
        System.assert(someShuttle != null);
        
    	Concur_Batch__c newBatch = [SELECT Id, Staged__c FROM Concur_Batch__c WHERE Id = :batchId];
        System.assert(true, newBatch.Staged__c);
    }
}