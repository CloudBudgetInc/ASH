global class ReconciliationsKickoffBatch implements Database.Batchable<sObject> {

    String company = 'ASH';
    String period = '';
    String account = '';
    
    public ReconciliationsKickoffBatch(String company, String period) {
        this.company = company;
        this.period = period;
    }    
    
    public ReconciliationsKickoffBatch(String company, String period, String account) {
        this.company = company;
        this.period = period;
        this.account = account;
    }       
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
      
        if(account == null || account.length() == 0 ) {
            String query = 'SELECT Id, General_Ledger_Account__c, User__c, Schedule__c, ' + 
                'Accounting_Company__c, Type__c, Templated_Note_Active__c, Templated_Note__c ' +
                'FROM Reconciliation_Template__c ' + 
                'WHERE Active__c = true AND Accounting_Company__r.Key__c = :company';
			return Database.getQueryLocator(query);
		}    
        else {
            String query = 'SELECT Id, General_Ledger_Account__c, User__c, Schedule__c, ' + 
                'Accounting_Company__c, Type__c, Templated_Note_Active__c, Templated_Note__c ' +
                'FROM Reconciliation_Template__c ' + 
                'WHERE Active__c = true AND Accounting_Company__r.Key__c = :company AND ' + 
                'General_Ledger_Account__r.c2g__ReportingCode__c = :account';  
			return Database.getQueryLocator(query);             
        }        
    }
    
   	global void execute(Database.BatchableContext BC, List<Reconciliation_Template__c> someRecTemplates) {
       
       	FfaDataProvider provider = FfaDataProvider.getInstance();
       	List<Reconciliation__c> reconciliations = new List<Reconciliation__c>();

        // Closing date represents the end of reconciliation period in question - it is 
        // often monthly, but sometimes quarterly, and is inclusive of the closing period in 
        // the latter scenario.
        // Opening date is only used in quarterly rec situations.
		Id reconciliationCompany = provider.getCompany(company);
        c2g__codaPeriod__c reconciliationPeriod = provider.getPeriod(company, period);
        Date closingDate = reconciliationPeriod.c2g__StartDate__c;
        Date openingDate = closingDate.addMonths(-2);
        Decimal year = Decimal.valueOf(period.left(4));
        Id fullIntersectDefId = provider.getIntersectDefinition('Full Accounting');
        
        // Need to set opening/closing balance. Query for reporting balances for this year, 
        // up to and including the period in question.
        Map<Id, c2g__ReportingBalance__c> allBalances = new Map<Id, c2g__ReportingBalance__c>(
        	[SELECT Id, c2g__Period__c, c2g__Period__r.c2g__PeriodNumber__c, c2g__GeneralLedgerAccount__c, c2g__HomeValue__c 
             FROM c2g__ReportingBalance__c 
             WHERE c2g__Type__c IN ('Actual')
             AND c2g__OwnerCompany__c = :reconciliationCompany
             AND c2g__IntersectDefinition__c = :fullIntersectDefId
             AND c2g__GeneralLedgerAccount__r.c2g__Type__c = 'Balance Sheet' 
             AND c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c <> '2999' 
             AND c2g__GeneralLedgerAccount__r.Is_Suspense__c = false
             AND c2g__YearNumber__c = :year
             AND c2g__Period__r.c2g__StartDate__c <= :closingDate // includes the period in question
             ORDER BY c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c, c2g__Period__r.c2g__StartDate__c]); 

        // Query for aggregate transaction counts for the period, grouped by General Ledger Account. 
        AggregateResult[] someTransactionCounts = [SELECT c2g__GeneralLedgerAccount__c glAccount, COUNT(Id) TransactionCount
        	FROM c2g__codaTransactionLineItem__c                                        
        	WHERE c2g__Transaction__r.c2g__Period__c = :reconciliationPeriod.Id AND 
        	c2g__Transaction__r.c2g__OwnerCompany__r.Id = :reconciliationCompany
			GROUP BY c2g__GeneralLedgerAccount__c];

        // Convert the agg result into a map for use later. This is a aggregation for the rec period.        
        Map<Id,Decimal> transactionCountsByGlAccountMonthly = new Map<Id, Decimal>();
        for(AggregateResult aggResult : someTransactionCounts) {
        	transactionCountsByGlAccountMonthly.put((Id)aggResult.get('glAccount'), (Decimal)aggResult.get('TransactionCount'));
        }
        
        // Aggregate transaction counts for the QUARTER, grouped by General Ledger Account. 
        AggregateResult[] someTransactionCounts2 = [SELECT c2g__GeneralLedgerAccount__c glAccount, COUNT(Id) TransactionCount
        	FROM c2g__codaTransactionLineItem__c 
            WHERE c2g__Transaction__r.c2g__Period__r.c2g__StartDate__c >= :openingDate AND
            c2g__Transaction__r.c2g__Period__r.c2g__StartDate__c <= :closingDate AND 
            c2g__Transaction__r.c2g__Period__r.c2g__PeriodNumber__c <> '000' AND  
        	c2g__Transaction__r.c2g__OwnerCompany__r.Id = :reconciliationCompany
			GROUP BY c2g__GeneralLedgerAccount__c];

        // Convert the agg result into a map for use later. We do this by quarter as well - 
        // for Quarterly reconciliations that span 3 periods.        
        Map<Id,Decimal> transactionCountsByGlAccountQuarterly = new Map<Id, Decimal>();
        for(AggregateResult aggResult : someTransactionCounts2) {
        	transactionCountsByGlAccountQuarterly.put((Id)aggResult.get('glAccount'), (Decimal)aggResult.get('TransactionCount'));
        }        
            
        // Create a reconciliation for each Reconciliation Template - both ASH and ASHRC.
       	for( Reconciliation_Template__c template : someRecTemplates ) {
            
            String generalLedgerAccount = template.General_Ledger_Account__c;
            
            if(template.Schedule__c == 'Monthly' || 
               (reconciliationPeriod.c2g__PeriodNumber__c == '003' || 
            	reconciliationPeriod.c2g__PeriodNumber__c == '006' || 
                reconciliationPeriod.c2g__PeriodNumber__c == '009' || 
                reconciliationPeriod.c2g__PeriodNumber__c == '012' )) {
            
                    Reconciliation__c someRec = new Reconciliation__c();
                    someRec.General_Ledger_Account__c = template.General_Ledger_Account__c;
                    someRec.User__c = template.User__c;
                    someRec.Reconciliation_Template__c = template.Id;
                    someRec.Accounting_Company__c = template.Accounting_Company__c;
                    someRec.Status__c = 'Open';
                    someRec.Period__c = reconciliationPeriod.Id;
                    
                    if(template.Templated_Note_Active__c == true) {
                        someRec.Notes__c = template.Templated_Note__c;
                    }
                    
                    // Transaction count handling. Used as an input to auto-close.
                    Decimal transactionCount;
                    if (template.Schedule__c == 'Monthly') { 
                    	transactionCount = transactionCountsByGlAccountMonthly.get(generalLedgerAccount);
                    } else {
                        transactionCount = transactionCountsByGlAccountQuarterly.get(generalLedgerAccount);
                    }
                    if(transactionCount == null) {
                        someRec.Transaction_Count__c = 0;
                    }
                    else {
                        someRec.Transaction_Count__c = transactionCount;
                    }

		            // Assign record type based on template.
        		    String recType = template.Type__c;
            		someRec.RecordTypeId = Schema.SObjectType.Reconciliation__c.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();		
            
            		Double currentBalance = 0.00;
		            Double closingBalance = 0.00;
        		    // Set the opening/closing balances on the Reconciliation record. 
        		    // Iterate through all reporting balances looking for previous and current
		            // period balances.
       				for( c2g__ReportingBalance__c someRepBalance : allBalances.values() ) {
		                if(someRepBalance.c2g__GeneralLedgerAccount__c == someRec.General_Ledger_Account__c) {
        		            closingBalance += someRepBalance.c2g__HomeValue__c;
                            
                            // We need to calculate balance activity for the period in question. Monthly is 
                            // fairly easy. Quarterly recs need to aggregate 3 periods worth of data.
                            if(template.Schedule__c == 'Monthly') { 
                                if(someRepBalance.c2g__Period__c == reconciliationPeriod.Id) {
                        			currentBalance = someRepBalance.c2g__HomeValue__c;
                                }
                    		} 
                            else {
                                if(Integer.valueOf(someRepBalance.c2g__Period__r.c2g__PeriodNumber__c) >= 
                                   (Integer.valueOf(reconciliationPeriod.c2g__PeriodNumber__c) - 2)) {
                                   currentBalance += someRepBalance.c2g__HomeValue__c;
                                 }
                            }
                		}
            		}
	    
                    someRec.Opening_Balance__c = closingBalance - currentBalance;
	    	        someRec.Closing_Balance__c = closingBalance;
            
                    if( someRec.Opening_Balance__c == someRec.Closing_Balance__c && 
                       (someRec.Transaction_Count__c == 0 || someRec.Transaction_Count__c == null)) {
                           someRec.Status__c = 'Auto_Closed';
                           someRec.Notes__c = 'Automatically closed by system.';
                    }
					reconciliations.add(someRec);
                }
		}
    	insert reconciliations;
   	}
    
    global void finish(Database.BatchableContext bc) { }
}