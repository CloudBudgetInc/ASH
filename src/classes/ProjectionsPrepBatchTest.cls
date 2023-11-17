@isTest(SeeAllData=true)
public class ProjectionsPrepBatchTest {
    
	static testMethod void testReportingBalanceUpdateTest() {   

        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someGlaAccount = provider.getGlaCode('7020');
        Id dim1 = provider.getDimension1('112');
        Id dim2 = provider.getDimension2('359');
        Id dim3 = provider.getDimension3('000');
        Id dim4 = provider.getDimension4('00');
        c2g__codaPeriod__c somePeriod1 = provider.getPeriod('ASH', '202509');
        c2g__codaPeriod__c somePeriod2 = provider.getPeriod('ASH', '202512');
        Id someCompany = provider.getCompany('ASH');
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');
        
        // Insert a Reporting Balance record of type 'Budget'.
        c2g__ReportingBalance__c budgetRepBalance1 = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Budget', c2g__HomeValue__c = 24.68, 
        	c2g__Period__c = somePeriod1.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert budgetRepBalance1;      
        
        // Insert a Reporting Balance record of type 'Budget'.
        c2g__ReportingBalance__c budgetRepBalance2 = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Budget', c2g__HomeValue__c = 75.32, 
        	c2g__Period__c = somePeriod2.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert budgetRepBalance2;          
        
        // Insert a Reporting Balance record of type 'Projection'.
        c2g__ReportingBalance__c projectionRepBalance = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Projection', c2g__HomeValue__c = 12.34, 
        	c2g__Period__c = somePeriod1.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert projectionRepBalance;

        Test.startTest();
        ProjectionsPrepBatch ppb = new ProjectionsPrepBatch('ASH', '2025', '202509');
        Id jobId = Database.executeBatch(ppb, 1);
        Test.stopTest();
        
		// Verify that the projection has correct values for Actuals YTD, Annual Budget, Budget YTD etc.
        c2g__ReportingBalance__c resultRepBalance = [SELECT Id, Actuals_YTD__c, Annual_Budget__c, 
            YTD_Budget__c, Amount__c, Annual_Projection__c FROM c2g__ReportingBalance__c 
        	WHERE CreatedDate = TODAY AND c2g__Type__c = 'Projection' AND Account_Subaccount__c = '7020-112-359-000-00'];
        System.assertEquals(0, resultRepBalance.Actuals_YTD__c);
        System.assertEquals(100.00, resultRepBalance.Annual_Budget__c);
        System.assertEquals(24.68, resultRepBalance.YTD_Budget__c);
        System.assertEquals(resultRepBalance.Amount__c, resultRepBalance.Annual_Projection__c);
    }
}