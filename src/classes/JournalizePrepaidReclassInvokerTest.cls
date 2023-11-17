@isTest(SeeAllData=true)
public class JournalizePrepaidReclassInvokerTest {
    
    public static testmethod void testBatchable() {
    
		Test.startTest();
      	List<String> params = new List<String>();
        FfaDataProvider provider = FfaDataProvider.getInstance();
		Finance_Support_Request__c someFsr = new Finance_Support_Request__c(Accounting_Company__c = provider.getCompany('ASH'), 
			Start_Date__c = Date.newInstance(2024,7,1), End_Date__c = Date.newInstance(2025,6,30));
        insert someFsr;    
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202312');
       	params.add(someFsr.Id);
        params.add(somePeriod.Id);
        List<List<String>> outerParams = new List<List<String>>();
        outerParams.add(params);
       	JournalizePrepaidReclassInvoker.invokePrepaidReclassJournalization(outerParams);
       	Test.stopTest();  
     
       	List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                     WHERE ApexClass.Name = 'JournalizePrepaidReclass' 
                                     AND JobType = 'BatchApex'
                                     AND CreatedDate = TODAY]; 
       	System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
    }
}