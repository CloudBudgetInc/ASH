public with sharing class CBExcelReport {

	@AuraEnabled
	public static Map<String, List<String>> getAvailableBudgetYearsServer() {
		Map<String, List<String>> r = new Map<String, List<String>>();

		Set<String> budgetYearSO = new Set<String>();
		for (c2g__codaYear__c year : [SELECT Name FROM c2g__codaYear__c ORDER BY Name]) budgetYearSO.add(year.Name);
		r.put('budgetYearSO', new List<String>(budgetYearSO));


		return r;
	}

	@AuraEnabled
	public static Map<String, List<String>> getNeededAnalyticsServer() {
		Map<String, List<String>> r = new Map<String, List<String>>();

		Set<String> budgetYearSO = new Set<String>();
		for (c2g__codaYear__c year : [SELECT Name FROM c2g__codaYear__c ORDER BY Name]) budgetYearSO.add(year.Name);
		r.put('budgetYearSO', new List<String>(budgetYearSO));

		Set<String> companySO = new Set<String>();
		for (c2g__codaCompany__c cmp : [SELECT Name FROM c2g__codaCompany__c ORDER BY Name]) companySO.add(cmp.Name);
		r.put('companySO', new List<String>(companySO));

		return r;
	}

	@AuraEnabled
	public static List<c2g__ReportingBalance__c> getReportDataServer(Integer selectedBY, String selectedCompany) {
		Integer previousYear = selectedBY - 1;
		Integer nextYear = selectedBY + 1;

		String sel = 'SELECT c2g__Type__c,Year__c,c2g__Dimension1__r.Name,c2g__Dimension2__r.Name,c2g__Dimension3__r.Name,' +
				'Income_Statement_Group__c,c2g__GeneralLedgerAccount__r.Name,Account_Subaccount__c,c2g__DualValue__c ';
		String frWhere = 'FROM c2g__ReportingBalance__c WHERE ';
		String isg = ' Income_Statement_Group__c IN (\'Income\', \'Program Expense\', \'Salary and Overhead\') ';
		String tb2 = ' AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance2__c IN (\'Expense\', \'Unrestricted Operating Revenue\') ';
		String companyFilter = ' AND c2g__OwnerCompany__r.Name = \'' + selectedCompany + '\' ';
		String amountFilter = ' AND c2g__DualValue__c != 0 ';
		String actualPlanFilter = ' AND ( (c2g__Type__c = \'Actual\' AND c2g__YearNumber__c = ' + previousYear + ' ) OR ' +
				' (c2g__Type__c = \'Budget\' AND (c2g__YearNumber__c = ' + selectedBY + ' OR c2g__YearNumber__c = ' + nextYear + ' )) ) ';

		//String orderBy = 'ORDER BY c2g__Dimension2__r.Name, c2g__Dimension3__r.Name, c2g__Type__c, c2g__GeneralLedgerAccount__r.Name';
		String orderBy = 'ORDER BY c2g__Dimension2__r.Name, c2g__Dimension3__r.Name, Income_Statement_Group__c, c2g__GeneralLedgerAccount__r.Name';
		String query = sel + frWhere + isg + tb2 + companyFilter + amountFilter + actualPlanFilter + orderBy;
		System.debug(query);

		return Database.query(query);
	}

}