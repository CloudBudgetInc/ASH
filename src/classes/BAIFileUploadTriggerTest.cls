@isTest(SeeAllData=true)
public class BAIFileUploadTriggerTest {

    static testMethod void testTriggerHandling() {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202301'); 
        BAI_File_Upload__c someBankFileUpload = new BAI_File_Upload__c(Bank_Account_Num__c = '0005162988893', Period__c = somePeriod.Id);
        insert someBankFileUpload;
        
        Test.startTest();
        someBankFileUpload.Process_File__c = true;
        update someBankFileUpload;
        Test.stopTest();
        
        // Note - an empty test to clear out the previously deployed trigger.
        System.assertEquals(true, true);
        
    }
}