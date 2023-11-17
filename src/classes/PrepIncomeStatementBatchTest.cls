@isTest(SeeAllData=true)
public class PrepIncomeStatementBatchTest {
  
    static testMethod void testPrepIncomeStatementBatch() { 

        String company = 'ASH';
        String period = '202202';
        Test.startTest();
        PrepIncomeStatementBatch pisb = new PrepIncomeStatementBatch(company, period);
        Id jobId = Database.executeBatch(pisb, 1000);
        Test.stopTest();

        // Our test here is pretty simple - did we generate records for the appropriate period?
        List<c2g__ReportingBalance__c> testResults = [SELECT Id FROM c2g__ReportingBalance__c 
          WHERE CreatedDate = TODAY AND c2g__Type__c = 'Current' and PerPost__c = :period];
        System.assert(testResults.size() > 0);
    }
}