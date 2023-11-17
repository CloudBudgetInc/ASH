@isTest(SeeAllData=true)
public class JournalizePrepaidReclassTest {

	public static testmethod void testJournalization() {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
		Finance_Support_Request__c someFsr = new Finance_Support_Request__c(Accounting_Company__c = provider.getCompany('ASH'), 
			Start_Date__c = Date.newInstance(2024,7,1), End_Date__c = Date.newInstance(2025,6,30));
        insert someFsr;
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202312');
        
        Related_Transaction__c relatedTransaction1 = new Related_Transaction__c(
            Original_Amount__c = 162340.00, 
            Type__c = 'Source',
			General_Ledger_Account__c = provider.getGlaCode('7020'), 
			Dimension_1__c = provider.getDimension1('112'),
			Dimension_2__c = provider.getDimension2('359'),
			Dimension_3__c = provider.getDimension3('000'),
			Dimension_4__c = provider.getDimension4('00'), 
            Finance_Support_Request__c = someFsr.Id);
        insert relatedTransaction1;
        
      	List<String> params = new List<String>();        
       	params.add(someFsr.Id);
        params.add(somePeriod.Id);
        List<List<String>> outerParams = new List<List<String>>();
        outerParams.add(params);
        Test.startTest();
       	JournalizePrepaidReclassInvoker.invokePrepaidReclassJournalization(outerParams);
       	Test.stopTest();  
        
        // Tests that the right journals were created in the correct quantities for the correct amounts.
        List<c2g__codaJournal__c> results = [SELECT Id, c2g__Debits__c, c2g__Credits__c FROM c2g__codaJournal__c 
          WHERE CreatedDate = TODAY AND c2g__Debits__c = 40585.00];
        System.assertEquals(4, results.size());	
        List<c2g__codaJournal__c> results2 = [SELECT Id, c2g__Debits__c, c2g__Credits__c FROM c2g__codaJournal__c 
          WHERE CreatedDate = TODAY AND c2g__Credits__c = -162340.00];
        System.assertEquals(1, results2.size());
    }        
}