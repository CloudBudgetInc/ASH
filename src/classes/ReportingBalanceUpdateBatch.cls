global class ReportingBalanceUpdateBatch implements Database.Batchable<sObject> {
    
    String companyKey = 'ASH';
    String perPost;  
    Integer year;
    Boolean productionMode;
    
    public ReportingBalanceUpdateBatch(String company, String perPost, String year, String mode) {
        this.companyKey = company;
        this.perPost = perPost;
        this.year = Integer.valueOf(year);
        this.productionMode = Boolean.valueOf(mode);
    }    
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
        List<String> glTypes = new List<String>();
        glTypes.add('Income');
        glTypes.add('Expense');
        List<String> types = new List<String>();
        if(productionMode == true) {
            types.add('Actual');
            types.add('Proxy');
        } else {
            types.add('Proxy');
        }
        
		String query = 'SELECT Id, Account_Subaccount__c, Annual_Budget__c, Actuals_YTD__c ' + 
            'FROM c2g__ReportingBalance__c ' + 
            'WHERE PerPost__c = :perPost AND ' +            
        	'c2g__OwnerCompany__r.Key__c = :companyKey AND ' +
            'c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN :glTypes AND ' + 
            'c2g__Type__c IN :types';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c> scope) {
        
   		FfaDataProvider provider = FfaDataProvider.getInstance();
		String companyId = provider.getCompany(companyKey);
        c2g__codaPeriod__c closingPeriod = provider.getPeriod(companyKey, perPost);        
        
        // Get all budgets for the current fiscal year, Income/Expense only.
        List<c2g__ReportingBalance__c> budgetBalances = [SELECT Account_Subaccount__c, c2g__HomeValue__c 
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Budget' 
            AND c2g__OwnerCompany__c = :companyId
            AND c2g__YearNumber__c = :year                                        
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')];
        
        // Get all projections (revised budgets) for the current fiscal year, Income/Expense only.
        List<c2g__ReportingBalance__c> projectionBalances = [SELECT Account_Subaccount__c, c2g__HomeValue__c 
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Projection' 
            AND c2g__OwnerCompany__c = :companyId
            AND c2g__YearNumber__c = :year                                        
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')];        
        
        // Get all actuals for the current fiscal year - up to and including the current period.
        // Income and expense only because that's all we care about for income statement purposes.
        Date closeDate = closingPeriod.c2g__StartDate__c;
        List<c2g__ReportingBalance__c> actualBalances = [SELECT Account_Subaccount__c, c2g__HomeValue__c 
            FROM c2g__ReportingBalance__c 
            WHERE c2g__Type__c = 'Actual' 
            AND c2g__OwnerCompany__c = :companyId
            AND c2g__YearNumber__c = :year
            AND c2g__Period__r.c2g__StartDate__c <= :closeDate  
            AND c2g__GeneralLedgerAccount__r.c2g__TrialBalance1__c IN ('Expense','Income')]; 
        
        List<c2g__ReportingBalance__c> forUpdate = new List<c2g__ReportingBalance__c>();
        
        for(c2g__ReportingBalance__c repBalance : scope) {
            // Initialize / re-initialize.
            repBalance.Actuals_YTD__c = 0.00;
            repBalance.Annual_Budget__c = 0.00;
            repBalance.Annual_Projection__c = 0.00;
            
            for(c2g__ReportingBalance__c someActualBalance : actualBalances) {
                if(someActualBalance.Account_Subaccount__c == repBalance.Account_Subaccount__c) {
                    repBalance.Actuals_YTD__c += someActualBalance.c2g__HomeValue__c;
                }
            }
            
            for(c2g__ReportingBalance__c someBudgetBalance : budgetBalances) {
                if(someBudgetBalance.Account_Subaccount__c == repBalance.Account_Subaccount__c) {
                    repBalance.Annual_Budget__c += someBudgetBalance.c2g__HomeValue__c;
                }
            }
            
            for(c2g__ReportingBalance__c someProjectionBalance : projectionBalances) {
                if(someProjectionBalance.Account_Subaccount__c == repBalance.Account_Subaccount__c) {
                    repBalance.Annual_Projection__c += someProjectionBalance.c2g__HomeValue__c;
                }
            }

            forUpdate.add(repBalance);
        }
        
        update forUpdate;
    }
    
    public void finish(Database.BatchableContext bc) {
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, 
                          CreatedBy.Email, ExtendedStatus FROM AsyncApexJob where Id = :bc.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'rtolocka.itconsultant@hematology.org'};
        mail.setToAddresses(toAddresses);        
        
      if(a.NumberOfErrors == 0) {        
            mail.setSubject('Prep Analytics - Complete');
            mail.setPlainTextBody('Prep Analytics complete for ' + companyKey + ', ' + perPost + '.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        else {
            mail.setSubject('Prep Analytics - Failed');
            mail.setPlainTextBody('Prep Analytics failed for ' + companyKey + ', ' + perPost + '.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });           
    	}
    }
}