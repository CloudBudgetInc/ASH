global class BudgetDetailImportBatchLoader implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);           
        
		String query = 'SELECT Id, Amount__c, Company__c, Acct_Subaccount__c, Comments__c ' +
        'FROM Budget_Detail_Import__c ' + 
        'WHERE Processed__c = false AND Company__c = :companyKey';
		return Database.getQueryLocator(query);
	}
	
    global void execute(Database.BatchableContext BC, List<Budget_Detail_Import__c> scope) { 
    	
	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id companyId = provider.getCompany(companyKey);
        String year = String.valueOf(migrationParams[0].Year__c);
        
        List<Budget_Detail_Import__c> knockdowns = new List<Budget_Detail_Import__c>();
        List<Budget_Detail__c> someBudgetDetails = new List<Budget_Detail__c>();
        for( Budget_Detail_Import__c someBudgetImport : scope ) {
            Budget_Detail__c someBudgetDetail = new Budget_Detail__c();
            String acctSubaccount = someBudgetImport.Acct_Subaccount__c;
            someBudgetDetail.Accounting_Company__c = companyId;
            //7020-11235900000
			someBudgetDetail.General_Ledger_Account__c = provider.getGlaCode(acctSubaccount.substring(0,4));
            someBudgetDetail.Dimension_1__c = provider.getDimension1(acctSubaccount.substring(5,8));
            someBudgetDetail.Dimension_2__c = provider.getDimension2(acctSubaccount.substring(8,11));
            someBudgetDetail.Dimension_3__c = provider.getDimension3(acctSubaccount.substring(11,14));
            someBudgetDetail.Dimension_4__c = provider.getDimension4(acctSubaccount.substring(14,16));
            someBudgetDetail.Amount__c = Decimal.valueOf(someBudgetImport.Amount__c);
            someBudgetDetail.Comments__c = someBudgetImport.Comments__c;
            someBudgetDetail.Year__c = year;
			someBudgetDetails.add(someBudgetDetail);
            someBudgetImport.Processed__c = true;
            knockdowns.add(someBudgetImport);
        }
        insert someBudgetDetails;
        update knockdowns;
    }
    
    public void finish(Database.BatchableContext bc) { }    
}