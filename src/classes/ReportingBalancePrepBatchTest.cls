@isTest(SeeAllData=true)
public class ReportingBalancePrepBatchTest {
	
    static testMethod void testReportingBalancePrepBatch2() { 
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someGlaAccount = provider.getGlaCode('7020');
        Id dim1 = provider.getDimension1('112');
        Id dim2 = provider.getDimension2('359');
        Id dim3 = provider.getDimension3('000');
        Id dim4 = provider.getDimension4('00');
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202209');
        Id someCompany = provider.getCompany('ASH');
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');        
        
        // Because the system limits insertion of Reporting Balance of type 'Actual', we need to test this 
        // by inserting a Opening type. Odd, but gets the job done and is the only way to prevent this code from 
        // picking up multiple non-test records and causing the tests to fail.
        c2g__ReportingBalance__c repBalance = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Opening', c2g__HomeValue__c = 12.34, 
        	c2g__DualValue__c = 12.34, c2g__Period__c = somePeriod.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert repBalance;        
        
		// Test pre-condition - 
		// Set Period to 202209, Company - ASH, Year - 2022 in Custom Settings to match the code below.
        Test.startTest();
        ReportingBalancePrepBatch rbpb = new ReportingBalancePrepBatch();
        Id jobId = Database.executeBatch(rbpb, 1);
        Test.stopTest();

		// Setting the configuration to a period in the future, but in the current year, will guarantee lots 
		// of proxy records created, because it will fit the pattern of existing actuals for year but none for 
		// the current period.
        List<c2g__ReportingBalance__c> resultRepBalance = [SELECT Id, Annual_Budget__c, Annual_Projection__c, Actuals_YTD__c 
            FROM c2g__ReportingBalance__c 
        	WHERE CreatedDate = TODAY AND c2g__Type__c = 'Proxy' and PerPost__c = '202209'];
        System.assert(resultRepBalance.size() > 0);
    }
    
}