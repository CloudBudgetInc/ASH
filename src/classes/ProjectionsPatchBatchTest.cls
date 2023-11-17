@isTest(SeeAllData=true)
public class ProjectionsPatchBatchTest {

	static testMethod void testReportingBalanceUpdateTest() {   

        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someGlaAccount = provider.getGlaCode('7020');
        Id dim1 = provider.getDimension1('112');
        Id dim2 = provider.getDimension2('359');
        Id dim3 = provider.getDimension3('000');
        Id dim4 = provider.getDimension4('00');
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202509');
        Id someCompany = provider.getCompany('ASH');
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');
        
        // Insert a Reporting Balance record of type 'Proxy'.
        c2g__ReportingBalance__c repBalance = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Proxy', 
            Annual_Budget__c = 0.00, Actuals_YTD__c = 250000.34, 
        	c2g__Period__c = somePeriod.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert repBalance;

        Test.startTest();
        ProjectionsPatchBatch ppb = new ProjectionsPatchBatch('ASH', '2025', '202509');
        Id jobId = Database.executeBatch(ppb, 1);
        Test.stopTest();
        
		// Verify that the projection has values for Actuals YTD and budget. 
        c2g__ReportingBalance__c resultRepBalance = [SELECT Id, Annual_Budget__c, Annual_Projection__c, 
            Amount__c, Actuals_YTD__c, Comment_Required__c FROM c2g__ReportingBalance__c 
        	WHERE CreatedDate = TODAY AND c2g__Type__c = 'Projection' AND 
            Account_Subaccount__c = '7020-112-359-000-00' AND 
            Patch__c = true];
        System.assertEquals(250000.34, resultRepBalance.Actuals_YTD__c);
        System.assertEquals(true, resultRepBalance.Comment_Required__c);
        System.assertEquals(0, resultRepBalance.Annual_Budget__c);
    }
}