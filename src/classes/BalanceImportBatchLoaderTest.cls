@isTest(SeeAllData=true)
public class BalanceImportBatchLoaderTest {

	static testMethod void testBalanceBatchUpload() { 
     
        Balance_Import__c someBalanceImport = new Balance_Import__c(
        	Value__c = 34094.03, Account__c ='7020', PerPost__c = '202412',
        	Subaccount__c  = '11235900000', Company__c = 'ASH');

        someBalanceImport.Processed__c = false;
        insert someBalanceImport;
        
        Test.startTest();
        BalanceImportBatchLoader bibl = new BalanceImportBatchLoader();
        Id jobId = Database.executeBatch(bibl, 1);
        Test.stopTest();
        
        c2g__ReportingBalance__c someRepBalance = [SELECT Id, c2g__HomeValue__c FROM c2g__ReportingBalance__c  
        	WHERE CreatedDate = TODAY AND c2g__HomeValue__c = 34094.03];
        System.assertNotEquals(null, someRepBalance);
    }
}