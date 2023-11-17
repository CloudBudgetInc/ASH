@isTest(SeeAllData=true)
public class BudgetImportBatchLoaderTest {

	static testMethod void testBudgetBatchUpload() { 
     
        Budget_Import__c someBudgetImport = new Budget_Import__c(
        	Amount__c ='34094.03', General_Ledger_Code__c ='7020', PerPost__c = '202412',
        	Subaccount__c  = '11235900000', Company__c = 'ASH');

        someBudgetImport.Processed__c = false;
        insert someBudgetImport;
        
        Test.startTest();
        BudgetImportBatchLoader bibl = new BudgetImportBatchLoader();
        Id jobId = Database.executeBatch(bibl, 1);
        Test.stopTest();
        
        c2g__ReportingBalance__c someRepBalance = [SELECT Id, c2g__HomeValue__c FROM c2g__ReportingBalance__c  
        	WHERE CreatedDate = TODAY AND c2g__HomeValue__c = 34094.03];
        System.assertNotEquals(null, someRepBalance);
    }
}