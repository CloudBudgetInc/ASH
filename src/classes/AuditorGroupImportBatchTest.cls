@isTest(SeeAllData=true)
public class AuditorGroupImportBatchTest {

	static testMethod void testAuditorGroupImportBatchTest() {   
     
        Auditor_Group_Import__c auditGroupImport = new Auditor_Group_Import__c();
        auditGroupImport.Account__c = '7020';
        auditGroupImport.Subaccount__c = '11235900000';
        //auditGroupImport.Label__c = 'Some test label';
        auditGroupImport.Description__c = 'Some test description';
        insert auditGroupImport;
        
        Test.startTest();
        AuditorGroupImportBatch agib = new AuditorGroupImportBatch();
        Id jobId = Database.executeBatch(agib, 1);
        Test.stopTest();
        
        Auditor_Group__c auditorGroup = [SELECT Id FROM Auditor_Group__c WHERE CreatedDate = TODAY AND 
                                      Description__c = 'Some test description'];
        System.assert(auditorGroup != null);
    }
}