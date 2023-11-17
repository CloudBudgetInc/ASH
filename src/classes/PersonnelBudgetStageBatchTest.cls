@isTest(SeeAllData=true)
public class PersonnelBudgetStageBatchTest {

    /**
     * Basic test to get this deployed to production, mostly for storage/continuity needs: 
     * note that this code will typically execute in Sandbox due to data visibility considerations.
     */
	public static testmethod void testBasics() {
        
		Personnel_Budget_Batch__c someBatch = new Personnel_Budget_Batch__c(Year__c = '2024');
        insert someBatch;
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id company = provider.getCompany('ASH');
        Id department = provider.getDimension1('115');
        Id program = provider.getDimension2('364');            
        
        Budget_Position__c budgetPosition = new Budget_Position__c(
            Accounting_Company__c = company, 
            Department__c = department,
            Program__c = program,
        	Annual_Salary__c = 120000.00, 
            Bonus__c = 5000.00, 
            Bonus_Date__c = Date.newInstance(2024, 08, 01),
            Review_Date__c = Date.newInstance(2024, 10, 01), 
			Hire_Date__c = Date.newInstance(2021, 04, 01),
            Targeted_Increase__c = .015,
            Medical_Dental_and_Vision__c = 2500.00, 
            Benefits_Eligible__c = true,
            Executive_Disability_Amount__c = 0.00,
            Employer_457b_Contributions__c = 5600.00,
            Employee_Name__c = 'Ronald McDonald' );
        insert budgetPosition;

        Test.startTest();
        PersonnelBudgetStageBatch pbsb = new PersonnelBudgetStageBatch(someBatch.Id);
        Id jobid = Database.executeBatch(pbsb, 5);
        Test.stopTest();
        
        List<Personnel_Cost_Record__c> costRecords = [SELECT Id FROM Personnel_Cost_Record__c WHERE CreatedDate = TODAY];
        System.assert(costRecords.size() > 1);
    }
}