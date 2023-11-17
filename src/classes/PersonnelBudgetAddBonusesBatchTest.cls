@isTest(SeeAllData=true)
public class PersonnelBudgetAddBonusesBatchTest {

    /**
     * Basic smoke test to get this deployed to production, mostly for storage/continuity needs: 
     * note that this code will typically execute in Sandbox due to data visibility considerations.
     */    
	public static testmethod void testBasics() {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id company = provider.getCompany('ASH');
        Id department = provider.getDimension1('115');
        Id program = provider.getDimension2('364');         
        
		Bonus_Template__c someBonusTemplate = new Bonus_Template__c(
        	Accounting_Company__c = company,
            Program__c = program,
            Amount__c = 50000.00,
            Active__c = true
        );
        
        insert someBonusTemplate;
        
		Personnel_Budget_Batch__c someBatch = new Personnel_Budget_Batch__c(Year__c = '2024');
        insert someBatch;        
        
        Test.startTest();
        PersonnelBudgetAddBonusesBatch pbabb = new PersonnelBudgetAddBonusesBatch(someBatch.Id);
        Id jobid = Database.executeBatch(pbabb, 1);
        Test.stopTest();
    }
}