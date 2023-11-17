@isTest(SeeAllData=true)
public class BankStatementTriggerTest {

    static testMethod void testTriggerHandlingBAIFlavor() {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202301'); 
        Bank_Statement__c someBankStatement = new Bank_Statement__c(Bank_Account_Number__c = '0005162988893', 
			Format__c = 'BAI', Period__c = somePeriod.Id);
        insert someBankStatement;

        String header1 = '01,053101121,1218027612,201006,1720,131,80,1,2/\n';
        String header2 = '02,1218027612,053101121,1,200803,,USD,1/\n';
        String header3 = '03,0005162988893,USD,010,381485529,,,015,387620336,,,040,372107229,,,045/\n';        
        String detailLine1 = '88,367355436,,,050,370003165,,,063,20264900,,,072,9378300,,,074,10886600,,,100/\n';
        String detailLine2 = '88,20642146,13,,400,14507339,2,,470,0,,/\n';
        String detailLine3 = '16,115,312500,,000000002607945030,9478,/\n';
        String detailLine4 = '88,IND LBX DEPOSIT/\n';
        String detailLine5 = '88,MARYLAND LOCKBOX DEPOSIT\n';
		String detailLine6 = '16,115,2074090,,000000002607946995,9632,/\n';
        String detailLine7 = '88,IND LBX DEPOSIT/\n';
        String detailLine8 = '88,MARYLAND LOCKBOX DEPOSIT\n';
            
		String combinedLine = header1 + header2 + header3 + detailLine1 + detailLine2 + detailLine3 + 
            detailLine4 + detailLine5 + detailLine6 + detailLine7 + detailLine8;
                
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        contentVersion.PathOnClient = 'extract.txt'; // The files name, extension is very important here which will help the file in preview.
        contentVersion.Title = 'Sample Bank File Upload Extract'; // Display name of the files
        contentVersion.VersionData = Blob.valueOf(combinedLine);
        insert contentVersion;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = someBankStatement.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
        
        Test.startTest();
        someBankStatement.Process_File__c = true;
        update someBankStatement;
        Test.stopTest();
        
        // Very simple test (for now) - did we create bank statement lines related to the newly inserted statement?
        List<Bank_Statement_Line_Item__c> someBankLines = [SELECT Id FROM Bank_Statement_Line_Item__c WHERE Bank_Statement__c = :someBankStatement.Id];
        System.assert(someBankLines.size() > 0);
    }
    

    static testMethod void testTriggerHandlingCSVFlavor() {   
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202301'); 
        Bank_Statement__c someBankStatement = new Bank_Statement__c(Bank_Account_Number__c = '0005162988893', 
			Format__c = 'CSV', Period__c = somePeriod.Id);
        insert someBankStatement;        
    
		Attachment att = new Attachment(Name='test-journal.csv');
        String header = 'Post Date, Customer Ref, Debit, Credit, BAI Description, Detail, Account Number\n';
        String line1 = '4/3/2023,5.3201E+13,,4650,PREAUTHORIZED ACH CREDIT,Alpine Immune Sc/CDNOTHER                American Society of He,8524780446\n';
        String line2 = '4/3/2023,3.11002E+13,,42000,PREAUTHORIZED ACH CREDIT,SPARK THERAPEUTI/PAYMENT                 AMERICAN SOCIETY OF HE,8524780446\n'; 
    	String combinedJournal = header + line1 + line2;    
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        contentVersion.PathOnClient = 'someBankImport.csv'; // The files name, extension is very important here which will help the file in preview.
        contentVersion.Title = 'Some Bank Import'; // Display name of the files
        contentVersion.VersionData = Blob.valueOf(combinedJournal);
        insert contentVersion;       
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = someBankStatement.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;          
        
        Test.startTest();
        someBankStatement.Process_File__c = true;
        update someBankStatement;
        Test.stopTest();        
        
        // Very simple test (for now) - did we create bank statement lines related to the newly inserted statement?
        List<Bank_Statement_Line_Item__c> someBankLines = [SELECT Id FROM Bank_Statement_Line_Item__c WHERE Bank_Statement__c = :someBankStatement.Id];
        System.assert(someBankLines.size() > 0);        
    }
}