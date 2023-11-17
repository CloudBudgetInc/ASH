@isTest(SeeAllData=true)
public class ReportingBalanceUpdateBatchTest {
    
	static testMethod void testReportingBalanceUpdateTest() {   
        
        final String COMPANY_KEY = 'ASH';
        final String PER_POST = '202409';
        final String YEAR = '2024';  
        final String PRODUCTION_MODE = 'false';
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someGlaAccount = provider.getGlaCode('7020');
        Id dim1 = provider.getDimension1('112');
        Id dim2 = provider.getDimension2('359');
        Id dim3 = provider.getDimension3('000');
        Id dim4 = provider.getDimension4('00');
        c2g__codaPeriod__c somePeriod = provider.getPeriod(COMPANY_KEY, PER_POST);
        Id someCompany = provider.getCompany(COMPANY_KEY);
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');
        
        // Because the system limits insertion of Reporting Balance of type 'Actual', we need to test this 
        // by inserting a Proxy type. Odd, but gets the job done and is the only way to prevent this code from 
        // picking up multiple non-test records and causing the tests to fail.
        c2g__ReportingBalance__c repBalance = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Proxy', c2g__HomeValue__c = 12.34, 
        	c2g__DualValue__c = 12.34, c2g__Period__c = somePeriod.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert repBalance;
        
        c2g__ReportingBalance__c budgetRepBalance = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Budget', c2g__HomeValue__c = 100.34, 
        	c2g__DualValue__c = 100.34, c2g__Period__c = somePeriod.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert budgetRepBalance;
        
        Test.startTest();
        ReportingBalanceUpdateBatch rbub = new ReportingBalanceUpdateBatch(COMPANY_KEY, PER_POST, YEAR, PRODUCTION_MODE);
        Id jobId = Database.executeBatch(rbub, 1);
        Test.stopTest();
        
        c2g__ReportingBalance__c resultRepBalance = [SELECT Id, Annual_Budget__c, Annual_Projection__c, Actuals_YTD__c FROM c2g__ReportingBalance__c 
        	WHERE CreatedDate = TODAY AND c2g__Type__c = 'Proxy' AND c2g__HomeValue__c = 12.34];
        System.assertNotEquals(0, resultRepBalance.Annual_Budget__c);
        System.assertNotEquals(0, resultRepBalance.Annual_Projection__c);
    }
}