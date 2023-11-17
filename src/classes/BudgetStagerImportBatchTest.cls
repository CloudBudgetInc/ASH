@isTest(SeeAllData=true)
public class BudgetStagerImportBatchTest {

	static testMethod void testBudgetBatchUpload() { 
        
        Personnel_Budget_Batch__c someBatch = new Personnel_Budget_Batch__c(Year__c = '2024');
        insert someBatch;
        Budget_Stager_Import__c someBudgetImport = new Budget_Stager_Import__c(
        	Amount__c ='34094.03', Accounting_Code__c ='9035-302-359-000-26', Period__c = '202412',
        	Company__c = 'ASH');

        someBudgetImport.Processed__c = false;
        insert someBudgetImport;
        
        Test.startTest();
        BudgetStagerImportBatch bsib = new BudgetStagerImportBatch(someBatch.Id);
        Id jobId = Database.executeBatch(bsib, 1);
        Test.stopTest();
        
        Personnel_Budget_Stager__c someStager = [SELECT Id, Accounting_Code__c, Period__c, Amount__c FROM Personnel_Budget_Stager__c  
        	WHERE CreatedDate = TODAY AND Amount__c = 34094.03];
        System.assertNotEquals(null, someStager);
        //System.assertEquals('ASH', someStager.Company__c);
        System.assertEquals('9035-302-359-000-26', someStager.Accounting_Code__c);
        System.assertEquals('202412', someStager.Period__c);
    }
}