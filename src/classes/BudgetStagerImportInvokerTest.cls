@isTest(SeeAllData=true)
public class BudgetStagerImportInvokerTest {
    
  public static testmethod void testBatchable() {

		Test.startTest();
        Personnel_Budget_Batch__c someBatch = new Personnel_Budget_Batch__c(Year__c = '2024');
        insert someBatch;      
      	List<String> params = new List<String>();
       	params.add(someBatch.Id);
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
		BudgetStagerImportInvoker.invokeBudgetImport(outerParams);
       	Test.stopTest();  
     	
      	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'BudgetStagerImportBatch' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY];        
      	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
   }   
}