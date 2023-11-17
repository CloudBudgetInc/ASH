public class PrepAnalyticsInvokable {
 
    @InvocableMethod(label='Prep Analytics' 
                     description='Preps CRM analytics for the period in question, by executing data setup.' 
                     category='Reporting')
    public static void prepAnalytics(List<List<String>> params) {
        
        // Get the period in question.
		List<String> nestedParams = params.get(0);
        String company = nestedParams.get(0);
        String perPost = nestedParams.get(1);
        Boolean productionMode = Boolean.valueOf(nestedParams.get(2));
        FfaDataProvider provider = FfaDataProvider.getInstance();
		c2g__codaPeriod__c period = provider.getPeriod(company, perPost);
        String fiscalYear = String.valueOf(period.Fiscal_Year__c);
        
        // Delete all existing proxies. We'll be generating new ones via this method.        
        String proxyType = 'Proxy';
        List<c2g__ReportingBalance__c> forDelete = [SELECT Id FROM c2g__ReportingBalance__c 
			WHERE c2g__Period__r.Id = :period.Id AND c2g__Type__c = :proxyType];
		delete forDelete;
        
        // Setup.
        String actualType = 'Actual';
        List<String> categories = new List<String>();
        categories.add('Expense');
        categories.add('Income');
        List<String> projectionsAndBudgets = new List<String>();
        projectionsAndBudgets.add('Budget');
        projectionsAndBudgets.add('Projection');        
        
        // Query for all actuals from the period in question.
        List<c2g__ReportingBalance__c> actuals = [SELECT Id, Account_Subaccount__c, 
			Annual_Budget__c, Actuals_YTD__c FROM c2g__ReportingBalance__c 
			WHERE c2g__Period__r.Id = :period.Id AND c2g__Type__c = :actualType AND 
            c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN :categories];
        
        // Convert incoming actuals from List > Map, keyed by Acct-Subaccount, for easier searching later on.
        Map<String, c2g__ReportingBalance__c> actualsLookup = new Map<String, c2g__ReportingBalance__c>();
        for(c2g__ReportingBalance__c someRepBalance : actuals) {
            actualsLookup.put(someRepBalance.Account_Subaccount__c, someRepBalance);
        }        
        
     	// Get all budgets and projections for the current fiscal year.
        List<c2g__ReportingBalance__c> budgetBalances = [SELECT Account_Subaccount__c, c2g__Dimension1__c,
            c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__GeneralLedgerAccount__c, 
            c2g__HomeValue__c, c2g__OwnerCompany__c, c2g__Period__c, Amount__c
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c in :projectionsAndBudgets               
            AND c2g__OwnerCompany__c = :period.c2g__OwnerCompany__c
            AND Year__c = :fiscalYear
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN :categories];
             
        // Get all actuals for the current fiscal year prior to the current period.
        List<c2g__ReportingBalance__c> actualBalances = [SELECT Account_Subaccount__c, c2g__Dimension1__c,
            c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__GeneralLedgerAccount__c, 
            c2g__HomeValue__c, c2g__OwnerCompany__c, c2g__Period__c, Amount__c
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = :actualType
            AND c2g__OwnerCompany__c = :period.c2g__OwnerCompany__c
            AND c2g__Period__r.c2g__StartDate__c < :period.c2g__EndDate__c
            AND Year__c = :fiscalYear                                    
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')];
        System.debug('We have ' + actualBalances.size() + ' actual balances.');            
        
        // Merge the previous 2 query results into a single list.
        List<c2g__ReportingBalance__c> allBalances = new List<c2g__ReportingBalance__c>();
        allBalances.addAll(budgetBalances);
        allBalances.addAll(actualBalances);
        
        // Set up for insertion routine.
        Map<String, c2g__ReportingBalance__c> mapForInsert = new Map<String, c2g__ReportingBalance__c>();
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');     
        
        // Iterate through all budgets, projections, and (historic) actuals. If we don't find an 
        // actual for the current period, we need to insert a Proxy record to support YTD Actual/Budget/Projection
        // reporting on those numbers.
        // Note that using a map here allows us to eliminate duplicates rather handily.
        for(c2g__ReportingBalance__c someRepBalance : allBalances) {   
            if(!actualsLookup.containsKey(someRepBalance.Account_Subaccount__c) && 
                someRepBalance.Amount__c <> 0.00) {
        		c2g__ReportingBalance__c someProxy = new c2g__ReportingBalance__c();
                someProxy.c2g__Dimension1__c = someRepBalance.c2g__Dimension1__c;
                someProxy.c2g__Dimension2__c = someRepBalance.c2g__Dimension2__c;
                someProxy.c2g__Dimension3__c = someRepBalance.c2g__Dimension3__c;
                someProxy.c2g__Dimension4__c = someRepBalance.c2g__Dimension4__c;
                someProxy.c2g__GeneralLedgerAccount__c = someRepBalance.c2g__GeneralLedgerAccount__c;
                someProxy.c2g__HomeValue__c = 0.00;
                someProxy.c2g__OwnerCompany__c = someRepBalance.c2g__OwnerCompany__c;
                someProxy.c2g__Period__c = period.Id;
                someProxy.c2g__IntersectDefinition__c = intersectDefinition;
                someProxy.c2g__Type__c = 'Proxy';
                mapForInsert.put(someRepBalance.Account_Subaccount__c, someProxy);
            }
        }
    
        // Insert the proxies. 
        insert mapForInsert.values();
        
		// Our work here isn't done - we still need to aggregate the actuals, 
        // budgets, projections and update the proxies with that information. 
        // See ReportingBalanceUpdateBatch which is the second and final part of this process. 
        if(productionMode == true) {      
        	Id batchJobId = Database.executeBatch(
                new ReportingBalanceUpdateBatch(company, perPost, 
					String.valueOf(period.Fiscal_Year__c ), String.valueOf(productionMode)), 100); 
        }
	}
}