@isTest(SeeAllData=true)
public class PersonnelBudgetFlushStagersTest {

    /**
     * Basic smoke test to get this deployed to production, mostly for storage/continuity needs: 
     * note that this code will typically execute in Sandbox due to data visibility considerations.
     */    
	public static testmethod void testBasics() {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        
		Personnel_Budget_Batch__c someBatch = new Personnel_Budget_Batch__c(Year__c = '2024');
        insert someBatch;

		Personnel_Budget_Stager__c someStager = new Personnel_Budget_Stager__c(                 
            Period__c = '202402',
            Accounting_Company__c = provider.getCompany('ASH'),
            Program__c = '375',
            Amount__c = 144000/12,
            Type__c = 'Bonus Pool',
            Personnel_Budget_Batch__c = someBatch.Id,
            General_Ledger_Account__c = provider.getGlaCode('9045'),
            Dimension_1__c = provider.getDimension1('302'),
            Dimension_2__c = provider.getDimension2('375'),
            Dimension_3__c = provider.getDimension3('000'),
            Dimension_4__c = provider.getDimension4('00')  
        );        
        
        insert someStager;
        
        Test.startTest();
        PersonnelBudgetFlushStagers pbfs = new PersonnelBudgetFlushStagers(someBatch.Id);
        Id jobid = Database.executeBatch(pbfs, 1);
        Test.stopTest();        
    }
}