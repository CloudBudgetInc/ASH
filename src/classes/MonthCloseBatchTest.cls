@isTest(SeeAllData=true)
public class MonthCloseBatchTest {
    
	static testMethod void testMonthCloseBatch() {   
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someGlaAccount = provider.getGlaCode('7020');
        Id dim1 = provider.getDimension1('112');
        Id dim2 = provider.getDimension2('359');
        Id dim3 = provider.getDimension3('000');
        Id dim4 = provider.getDimension4('00');
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202401');
        Id someCompany = provider.getCompany('ASH');
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');
        
        // Because the system limits insertion of Reporting Balance of type 'Actual', we need to test this 
        // using a Opening type. Weird, but gets the job done and is the only way to prevent this code from 
        // picking up multiple non-test records and causing the tests to fail.
        c2g__ReportingBalance__c repBalance = new c2g__ReportingBalance__c( 
        	c2g__GeneralLedgerAccount__c = someGlaAccount, c2g__Dimension1__c = dim1, c2g__Dimension2__c = dim2, 
        	c2g__Dimension3__c = dim3, c2g__Dimension4__c = dim4, c2g__Type__c = 'Opening', c2g__HomeValue__c = 50.00, 
        	c2g__DualValue__c = 50.00, c2g__Period__c = somePeriod.Id, c2g__IntersectDefinition__c = intersectDefinition,
        	 c2g__OwnerCompany__c = someCompany);
        insert repBalance;
        
        Test.startTest();     
        MonthCloseBatch mcb = new MonthCloseBatch('ASH', '202401');
        Id jobId = Database.executeBatch(mcb, 1);
        Test.stopTest();
        
        c2g__codaJournal__c someJournal = [SELECT Id, c2g__Debits__c, c2g__Credits__c, c2g__Total__c 
                                           FROM c2g__codaJournal__c WHERE CreatedDate = TODAY 
                                           AND c2g__JournalStatus__c = 'In Progress'
                                           AND c2g__JournalDescription__c LIKE '%2999%'];
        System.assertNotEquals(someJournal, null);
        System.assertEquals(0.00, someJournal.c2g__Total__c);
    }
}