global class ReportingBalancePrepBatch implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
       	List<Month_Close__c> params = Month_Close__c.getall().values();
		String companyKey = String.valueOf(params[0].Company__c);  
	    String perPost = String.valueOf(params[0].PerPost__c);
        String type = String.valueOf(params[0].Type__c); // always 'Actual' in Production.
        List<String> categories = new List<String>();
        categories.add('Expense');
        categories.add('Income');
		String query = 'SELECT Id, Account_Subaccount__c, Annual_Budget__c, Actuals_YTD__c ' + 
            'FROM c2g__ReportingBalance__c ' + 
            'WHERE PerPost__c = :perPost AND ' +            
        	'c2g__OwnerCompany__r.Key__c = :companyKey AND ' +
            'c2g__Type__c = :type AND ' + 
            'c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN :categories';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c > scope) {
        
        // Data setup.
   		FfaDataProvider provider = FfaDataProvider.getInstance();        
	    List<Month_Close__c> params = Month_Close__c.getall().values();
		String companyKey = String.valueOf(params[0].Company__c);  
	    Integer year = Integer.valueOf(params[0].Year__c);
        Id thisCompanyId = provider.getCompany(companyKey); 
	    String perPost = String.valueOf(params[0].PerPost__c);
        c2g__codaPeriod__c closingPeriod = provider.getPeriod(companyKey, perPost);
        Date closeDate = closingPeriod.c2g__StartDate__c;
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');        
        
        // This job cannot be run when there are already proxy Reporting Balances in the period.
        // The following code guards against re-runs of this process - which would surely result in 
        // duplicate records and would break reporting, create havoc, tears, unemployment, etc.
        String proxy = 'Proxy';
        List<c2g__ReportingBalance__c> existingProxyBalances = [SELECT Id FROM c2g__ReportingBalance__c 
            WHERE PerPost__c = :perPost AND c2g__OwnerCompany__r.Key__c = :companyKey AND c2g__Type__c = :proxy];
        if(existingProxyBalances.size() > 0) {
            System.debug('Proxies exist; bailing out.');
            return;
        }
        
        // Convert incoming actuals from List > Map, keyed by Acct-Subaccount, for easier searching later on.
        Map<String, c2g__ReportingBalance__c> actualsLookup = new Map<String, c2g__ReportingBalance__c>();
        for(c2g__ReportingBalance__c someRepBalance : scope) {
            actualsLookup.put(someRepBalance.Account_Subaccount__c, someRepBalance);
        }
        System.debug('Done converting actuals from List to Map.');
        
        // Get all budgets for the current fiscal year.
        List<c2g__ReportingBalance__c> budgetBalances = [SELECT Account_Subaccount__c, c2g__Dimension1__c,
            c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__GeneralLedgerAccount__c, 
            c2g__HomeValue__c, c2g__OwnerCompany__c, c2g__Period__c, Amount__c
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Budget' 
            AND c2g__OwnerCompany__c = :thisCompanyId
            AND c2g__YearNumber__c = :year                                        
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')];
        System.debug('We have ' + budgetBalances.size() + ' budget balances.');
        
        // Get all projections (i.e. revised budgets) for the current fiscal year.
        List<c2g__ReportingBalance__c> projectionBalances = [SELECT Account_Subaccount__c, c2g__Dimension1__c,
            c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__GeneralLedgerAccount__c, 
            c2g__HomeValue__c, c2g__OwnerCompany__c, c2g__Period__c, Amount__c
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Projection' 
            AND c2g__OwnerCompany__c = :thisCompanyId
            AND c2g__YearNumber__c = :year                                        
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')];
        System.debug('We have ' + projectionBalances.size() + ' projection balances.');        
        
        // Get all actuals for the current fiscal year prior to the current period.
        List<c2g__ReportingBalance__c> actualBalances = [SELECT Account_Subaccount__c, c2g__Dimension1__c,
            c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__GeneralLedgerAccount__c, 
            c2g__HomeValue__c, c2g__OwnerCompany__c, c2g__Period__c, Amount__c
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Actual' 
            AND c2g__OwnerCompany__c = :thisCompanyId
            AND c2g__YearNumber__c = :year
            AND c2g__Period__r.c2g__StartDate__c < :closeDate  
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')];
        System.debug('We have ' + actualBalances.size() + ' actual balances.');            
        
        // Merge the previous 3 query results into a single list.
        List<c2g__ReportingBalance__c> allBalances = new List<c2g__ReportingBalance__c>();
        allBalances.addAll(budgetBalances);
        allBalances.addAll(projectionBalances);
        allBalances.addAll(actualBalances);
        
        Map<String, c2g__ReportingBalance__c> mapForInsert = new Map<String, c2g__ReportingBalance__c>();
                
        // Iterate through all budgets, projections, and (historic) actuals. If we don't find an 
        // actual for the current period, we need to insert a Proxy record to support YTD Actual/Budget/Projection
        // reporting on those numbers. Note that this code requires a large (750+) batch size to work.
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
                someProxy.c2g__Period__c = closingPeriod.Id;
                someProxy.c2g__IntersectDefinition__c = intersectDefinition;
                someProxy.c2g__Type__c = 'Proxy';
                mapForInsert.put(someRepBalance.Account_Subaccount__c, someProxy);
            }
        }
		
		// Insert the proxies. Our work here isn't done - we still need to aggregate the actuals, 
		// budgets, projections and update the proxies with that information. 
		// See ReportingBalanceUpdateBatch which is the second and final part of this process.
        insert mapForInsert.values();
    }
    
    public void finish(Database.BatchableContext bc) {}
}