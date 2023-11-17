@isTest(SeeAllData=true)
public class ProjectionsCloseBatchTest {
    
	static testMethod void testProjectionsCloseTest() {   

        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someGlaAccount = provider.getGlaCode('7020');
        Id dim1 = provider.getDimension1('112');
        Id dim2 = provider.getDimension2('359');
        Id dim2Other = provider.getDimension2('368');
        Id dim3 = provider.getDimension3('000');
        Id dim4 = provider.getDimension4('00');
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202409');
        Id someCompany = provider.getCompany('ASH');
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');

        c2g__ReportingBalance__c repBalance = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, Revised_Projection__c = 350.00, c2g__Type__c = 'Projection', 
            c2g__HomeValue__c = 257.00,  c2g__Period__c = somePeriod.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert repBalance;
        Id testRecordId = repBalance.Id;
        
        c2g__ReportingBalance__c otherRepBalance = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2Other, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Projection', 
            c2g__HomeValue__c = 257.00,  c2g__Period__c = somePeriod.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert otherRepBalance;
        Id testRecordIdTwo = otherRepBalance.Id;        

        Test.startTest();
        ProjectionsCloseBatch pcb = new ProjectionsCloseBatch('ASH', '2024', '202409');
        Id jobId = Database.executeBatch(pcb, 2);
        Test.stopTest();
        
        c2g__ReportingBalance__c resultRepBalance = [SELECT Id, Q3_Projection__c, Revised_Projection__c, 
            c2g__HomeValue__c FROM c2g__ReportingBalance__c WHERE Id = :testRecordId];
        System.assertEquals(resultRepBalance.Q3_Projection__c, resultRepBalance.Revised_Projection__c);
        System.assertEquals(resultRepBalance.c2g__HomeValue__c, resultRepBalance.Revised_Projection__c);
        
        c2g__ReportingBalance__c resultRepBalance2 = [SELECT Id, Q3_Projection__c, Revised_Projection__c, 
            c2g__HomeValue__c FROM c2g__ReportingBalance__c WHERE Id = :testRecordIdTwo];
        System.assertEquals(resultRepBalance2.Q3_Projection__c, resultRepBalance2.c2g__HomeValue__c);      
    }
}