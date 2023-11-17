@isTest(SeeAllData=true)
public class BudgetDetailImportBatchLoaderTest {

	static testMethod void testBudgetDetailBatchUpload() { 
     
        Budget_Detail_Import__c someBudgetDetailImport = new Budget_Detail_Import__c(
        	Amount__c ='34094.03', Processed__c = false, Comments__c = 'Big Huge Test',
        	Acct_Subaccount__c  = '7020-11235900000', Company__c = 'ASH');

        insert someBudgetDetailImport;
        
        Test.startTest();
        BudgetDetailImportBatchLoader bdibl = new BudgetDetailImportBatchLoader();
        Id jobId = Database.executeBatch(bdibl, 1);
        Test.stopTest();
        
        Budget_Detail__c someBudgetDetail = [SELECT Id, Amount__c FROM Budget_Detail__c  
        	WHERE CreatedDate = TODAY AND Amount__c = 34094.03];
        System.assertNotEquals(null, someBudgetDetail);
    }
}