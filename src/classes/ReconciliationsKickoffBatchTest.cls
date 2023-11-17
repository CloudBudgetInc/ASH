@isTest(SeeAllData=true)
public class ReconciliationsKickoffBatchTest {
    
	static testMethod void testReconciliationsKickoffBatch() { 
        
        String glaCode = '7020';
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someCompany = provider.getCompany('ASH');
        Id someGla = provider.getGlaCode(glaCode);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='thisafakeuser@hematology.org', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='thisafakeuser@hematology.org');
        insert u;
        
        Reconciliation_Template__c someRecTemplate = new Reconciliation_Template__c(
	        Accounting_Company__c = someCompany, User__c = u.Id, Schedule__c = 'Monthly',
			Active__c = true, General_Ledger_Account__c = someGla);
        
        insert someRecTemplate;
        
        Test.startTest();
        ReconciliationsKickoffBatch rkb = new ReconciliationsKickoffBatch('ASH','202303',glaCode);
        Id jobId = Database.executeBatch(rkb, 1);
        Test.stopTest();
        
        Reconciliation__c someRec = [SELECT Id FROM Reconciliation__c WHERE CreatedDate = TODAY AND User__c = :u.Id];
        System.assertNotEquals(null, someRec);
    }
}