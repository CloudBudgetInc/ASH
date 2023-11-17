global class BudgetImportBatchLoader implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

        // Originally written to import budget Reporting Balances, I parameterized this so it can 
        // be used to import any type of Reporting Balance.
	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);           
        
		String query = 'SELECT Id, Amount__c, Company__c, General_Ledger_Code__c, Subaccount__c, PerPost__c ' +
        'FROM Budget_Import__c ' + 
        'WHERE Processed__c = false AND Company__c = :companyKey';
		return Database.getQueryLocator(query);
	}
	
    global void execute(Database.BatchableContext BC, List<Budget_Import__c> scope) { 
    	
	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);  
        String type = String.valueOf(migrationParams[0].Type__c);  
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id companyId = provider.getCompany(companyKey);
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');
        
        List<Budget_Import__c> knockdowns = new List<Budget_Import__c>();
        List<c2g__ReportingBalance__c> someReportingBalances = new List<c2g__ReportingBalance__c>();
        for( Budget_Import__c someBudgetImport : scope ) {
            c2g__ReportingBalance__c someReportingBalance = new c2g__ReportingBalance__c();
            String subaccount = someBudgetImport.Subaccount__c;
            someReportingBalance.c2g__OwnerCompany__c = companyId;
			someReportingBalance.c2g__Type__c = type;
			someReportingBalance.c2g__GeneralLedgerAccount__c = provider.getGlaCode(someBudgetImport.General_Ledger_Code__c );
            someReportingBalance.c2g__Dimension1__c = provider.getDimension1(subaccount.substring(0,3));
            someReportingBalance.c2g__Dimension2__c = provider.getDimension2(subaccount.substring(3,6));
            someReportingBalance.c2g__Dimension3__c = provider.getDimension3(subaccount.substring(6,9));
            someReportingBalance.c2g__Dimension4__c = provider.getDimension4(subaccount.substring(9,11));
            someReportingBalance.c2g__HomeValue__c = Decimal.valueOf(someBudgetImport.Amount__c);
            someReportingBalance.c2g__DualValue__c = Decimal.valueOf(someBudgetImport.Amount__c);
            someReportingBalance.c2g__Period__c = provider.getPeriod(companyKey, someBudgetImport.PerPost__c).Id;
            System.debug(someReportingBalance.c2g__Period__c);
            someReportingBalance.c2g__IntersectDefinition__c = intersectDefinition;
			someReportingBalances.add(someReportingBalance);
            someBudgetImport.Processed__c = true;
            knockdowns.add(someBudgetImport);
        }
        insert someReportingBalances;
        update knockdowns;
    }
    
    public void finish(Database.BatchableContext bc) { }    
}