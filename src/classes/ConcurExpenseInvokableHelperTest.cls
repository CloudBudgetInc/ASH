@isTest(SeeAllData=true)
public class ConcurExpenseInvokableHelperTest {
    
	public static testmethod void testStagingBatchable() {
        
        Concur_Batch__c someBatch = new Concur_Batch__c(Processed__c = false, Type__c = 'Expense');
        insert someBatch;
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

		Test.StartTest();
	    List<String> innerParams = new List<String>();    
        innerParams.add('Stage');
     	innerParams.add('ASH');
        innerParams.add(someBatch.Id);
        List<List<String>> outerParams = new List<List<String>>();
        outerParams.add(innerParams);
     	ConcurExpenseInvokableHelper.invokeConcurExpense(outerParams);
     	Test.StopTest();  
     
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ConcurStageExpenseBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
 	}   
    
	public static testmethod void testProcessBatchable() {

		Concur_Batch__c someBatch = new Concur_Batch__c(Batch_ID__c = '9997');
        insert someBatch;        
        
        Payment_Shuttle__c shuttleOne = new Payment_Shuttle__c(Invoice_Number__c = 'AAAAA100', Vendor_ID__c = 'STEI06',
             Intercompany_ID__c = 'ASHRC', Transaction_Amount__c = '400.00', Apply_Date__c = '2023-01-17', 
             Description_1__c = 'Test Description', Description_2__c = 'Test Description 2', Company_ID__c = 'ASH', 
             Account_Code__c = '7020', Department__c = '112', Program__c = '359', Payment_Type__c = 'REIM', Other_Payment_Type__c = 'Company',
             Project__c = '000', Other__c = '00', Invoice_Date__c = '2023-01-17', Expense_Year__c = '2023', X1099_Number__c = '7', 
             Concur_Key__c = '4509303', Concur_Id__c = '3049303', Processed__c = false, Type__c = 'Expense', 
             Batch__c = '9997', Concur_Batch__c = someBatch.Id);       
        insert shuttleOne;   
        
		Test.StartTest();
	    List<String> innerParams = new List<String>();    
        innerParams.add('Process');
     	innerParams.add('ASH');
        innerParams.add(someBatch.Id);
        List<List<String>> outerParams = new List<List<String>>();
        outerParams.add(innerParams);
     	ConcurExpenseInvokableHelper.invokeConcurExpense(outerParams);
     	Test.StopTest();       
        
     	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'ConcurProcessExpenseBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
     	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);                
    }
}