global class ProjectionsPatchBatch implements Database.Batchable<sObject> {

    String company = 'ASH';
    String year;
    String period;
    
    /** 
     * This code queries for Reporting Balances of type 'Actual'/'Proxy' where we have spend/income 
     * but no budget, then inserts a 'Patch' Projection record if none exists.
     * This is necessary because Projections are initially created from 
	 * Budget records, so these 'rogue' actuals will have no Projection for data entry otherwise.
     * It then flags it for Finance review if it sits above a certain threshold. 
	*/
    public ProjectionsPatchBatch(String company, String year, String period) {
        this.company = company;
        this.year = year;
        this.period = period; // e.g 202409
    }      
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        
		String profitAndLoss = 'Profit and Loss';         
        Integer yearAsInteger = Integer.valueOf(year); 
        List<String> balanceTypes = new List<String>();
        balanceTypes.add('Actual');
        balanceTypes.add('Proxy');
        List<String> trialBalanceCategories = new List<String>();
        trialBalanceCategories.add('Expense');
        trialBalanceCategories.add('Unrestricted Operating Revenue');  
        
        String query = 'SELECT Id, Actuals_YTD__c, Annual_Budget__c, Account_Subaccount__c, ' + 
			'c2g__Dimension1__c, c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, ' + 
			'c2g__GeneralLedgerAccount__c, c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c ' + 
			'FROM c2g__ReportingBalance__c ' + 
            'WHERE c2g__Type__c IN :balanceTypes ' + 
            'AND c2g__YearNumber__c = :yearAsInteger ' + 
            'AND c2g__Period__r.PerPost__c = :period ' +
            'AND c2g__GeneralLedgerAccount__r.c2g__Type__c = :profitAndLoss ' +
            'AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance2__c IN :trialBalanceCategories ' + 
			'AND c2g__OwnerCompany__r.Key__c = :company ' + 
        	'AND Actuals_YTD__c <> 0.00 ' + 
			'AND Annual_Budget__c = 0.00 ' +             
			'ORDER BY c2g__Dimension2__r.Name, c2g__GeneralLedgerAccount__r.Name';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c> scope) { 
        
        // Data setup for subsequent queries.
   		FfaDataProvider provider = FfaDataProvider.getInstance();
	    Integer yearAsInteger = Integer.valueOf(year);
        Id companyId = provider.getCompany(company);
        c2g__codaPeriod__c closingPeriod = provider.getPeriod(company, period);
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');         
        
        // Get all projections for the selected fiscal year, Income/Expense only.
        List<c2g__ReportingBalance__c> projectionBalances = [SELECT Account_Subaccount__c, c2g__HomeValue__c 
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Projection' 
            AND c2g__OwnerCompany__c = :companyId
            AND c2g__YearNumber__c = :yearAsInteger                                        
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')];  
        
        // Convert projections from List > Map, keyed by Acct-Subaccount, for easier lookup down below.
        Map<String, c2g__ReportingBalance__c> projectionsLookup = new Map<String, c2g__ReportingBalance__c>();
        for(c2g__ReportingBalance__c someRepBalance : projectionBalances) {
            projectionsLookup.put(someRepBalance.Account_Subaccount__c, someRepBalance);
        }
        
        // Loop the list of unbudgeted actuals and insert a projection if one isn't found.
        // Projections are flagged as 'patch'. Any above a certain threshold are flagged 
        // for attention.
        List<c2g__ReportingBalance__c> forInsert = new List<c2g__ReportingBalance__c>();
        for( c2g__ReportingBalance__c someBalance : scope ) {
            if( projectionsLookup.get(someBalance.Account_Subaccount__c) == null) {
                
                c2g__ReportingBalance__c newBalance = new c2g__ReportingBalance__c( 
                     c2g__GeneralLedgerAccount__c = someBalance.c2g__GeneralLedgerAccount__c, 
                     c2g__Dimension1__c = someBalance.c2g__Dimension1__c, 
                     c2g__Dimension2__c = someBalance.c2g__Dimension2__c, 
                     c2g__Dimension3__c = someBalance.c2g__Dimension3__c, 
                     c2g__Dimension4__c = someBalance.c2g__Dimension4__c,
                     c2g__IntersectDefinition__c = intersectDefinition,
                     c2g__Type__c = 'Projection',
                     Actuals_YTD__c = someBalance.Actuals_YTD__c, 
                     Annual_Projection__c = .01,
                     Annual_Budget__c = 0.00,
                     c2g__HomeValue__c = 0.00,
                     c2g__Period__c = closingPeriod.Id,
                     Patch__c = true
                );
                
                if( someBalance.Actuals_YTD__c > 250000 || someBalance.Actuals_YTD__c < -250000 ) {
                    newBalance.Comment_Required__c = true;
                }
				forInsert.add(newBalance);                            
            } 
        }
        insert forInsert;
    }    

    global void finish(Database.BatchableContext bc) { }    
}