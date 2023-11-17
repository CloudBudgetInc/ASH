global class ProjectionsPrepBatch implements Database.Batchable<sObject> {
    
    String company = 'ASH';
    String year;
    String period;
    
    /**
     * Batch job that updates all Income/Expense projections with Actuals/Budget numbers as a preparatory step for the 
     * quarterly projections process. 
     */
    public ProjectionsPrepBatch(String company, String year, String period) {
        this.company = company;
        this.year = year;
        this.period = period;
    }        
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
		String profitAndLoss = 'Profit and Loss'; 
        Integer yearAsInteger = Integer.valueOf(year); 
        String balanceType = 'Projection';
		String query = 'SELECT Id, Account_Subaccount__c, Annual_Budget__c, YTD_Budget__c, Actuals_YTD__c, ' + 
            'c2g__HomeValue__c, Annual_Projection__c ' + 
            'FROM c2g__ReportingBalance__c ' + 
            'WHERE c2g__OwnerCompany__r.Key__c = :company AND ' +
            'c2g__Type__c = :balanceType AND ' + 
            'c2g__YearNumber__c = :yearAsInteger AND ' + 
            'c2g__GeneralLedgerAccount__r.c2g__Type__c = :profitAndLoss';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c > scope) {
        
        // Data setup for subsequent queries.
   		FfaDataProvider provider = FfaDataProvider.getInstance();
	    Integer yearAsInteger = Integer.valueOf(year);
        Id companyId = provider.getCompany(company); 
        c2g__codaPeriod__c closingPeriod = provider.getPeriod(company, period);
        Date closeDate = closingPeriod.c2g__StartDate__c;
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');        
        
        // Get all budgets for the current fiscal year, Income/Expense only.
        List<c2g__ReportingBalance__c> budgetBalances = [SELECT Account_Subaccount__c, 
			c2g__HomeValue__c, c2g__Period__r.c2g__StartDate__c
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Budget' 
            AND c2g__OwnerCompany__c = :companyId
            AND c2g__YearNumber__c = :yearAsInteger                                        
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')]; 
        
        // Convert budgets from List > Map, keyed by Acct-Subaccount, for easier lookup later on.
        Map<String, c2g__ReportingBalance__c> budgetsLookup = new Map<String, c2g__ReportingBalance__c>();
        for(c2g__ReportingBalance__c someRepBalance : budgetBalances) {
            budgetsLookup.put(someRepBalance.Account_Subaccount__c, someRepBalance);
        }
        
        // Get all actuals for the current fiscal year - up to and including the current period.
        // Income and expense only because that's all we care about for income statement purposes.
        List<c2g__ReportingBalance__c> actualBalances = [SELECT Account_Subaccount__c, c2g__HomeValue__c 
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Actual' 
            AND c2g__OwnerCompany__c = :companyId
            AND c2g__YearNumber__c = :yearAsInteger
            AND c2g__Period__r.c2g__StartDate__c <= :closeDate  
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')];    
                
        // Convert actuals from List > Map, keyed by Acct-Subaccount, for easier lookup later on.
        Map<String, c2g__ReportingBalance__c> actualsLookup = new Map<String, c2g__ReportingBalance__c>();
        for(c2g__ReportingBalance__c someRepBalance : actualBalances) {
            actualsLookup.put(someRepBalance.Account_Subaccount__c, someRepBalance);
        }

        // Loop the projections and update their actuals YTD and Budget Numbers accordingly.        
        List<c2g__ReportingBalance__c> forUpdate = new List<c2g__ReportingBalance__c>();
        for(c2g__ReportingBalance__c repBalance : scope) {   
            
            repBalance.Actuals_YTD__c = 0.00;
            repBalance.Annual_Budget__c = 0.00;
            repBalance.YTD_Budget__c = 0.00;
            repBalance.Annual_Projection__c = repBalance.c2g__HomeValue__c;
            // Reset user-entered values.
            repBalance.Revised_Projection__c = null;
            // Do not wipe comments - it is valuable to see their previous comment when doing assessment.
            //repBalance.Comments__c = null;
            repBalance.Finance_Comments__c = null;
            repBalance.Comment_Required__c = false;
            
            for(c2g__ReportingBalance__c someActualBalance : actualBalances) {
                if(someActualBalance.Account_Subaccount__c == repBalance.Account_Subaccount__c) {
                    repBalance.Actuals_YTD__c += someActualBalance.c2g__HomeValue__c;
                }
            }
            
            for(c2g__ReportingBalance__c someBudgetBalance : budgetBalances) {
                if(someBudgetBalance.Account_Subaccount__c == repBalance.Account_Subaccount__c) {
                    repBalance.Annual_Budget__c += someBudgetBalance.c2g__HomeValue__c;
                    if( someBudgetBalance.c2g__Period__r.c2g__StartDate__c <= closeDate ) {
                    	repBalance.YTD_Budget__c += someBudgetBalance.c2g__HomeValue__c;                        
                    }
                }
            }
            forUpdate.add(repBalance);
        }
		
        update forUpdate;
    }
    
    public void finish(Database.BatchableContext bc) {}
}