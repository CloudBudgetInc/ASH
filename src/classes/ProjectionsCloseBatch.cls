global class ProjectionsCloseBatch implements Database.Batchable<sObject> {

    String company = 'ASH';
    String year;
    String period;
    
    /** This class effectively closes out the projection process, by rolling the "Revised Projection" field back to the 
     * Home Value on the Projection. It also logs the value in a quarterly, historical tracking field (Q1, Q2, Q3, Q4).
     */
    public ProjectionsCloseBatch(String company, String year, String period) {
        this.company = company;
        this.year = year;
        this.period = period;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
		
        String type = 'Projection';
		String profitAndLoss = 'Profit and Loss';   
        Integer yearAsInteger = Integer.valueOf(year);
        String query = 'SELECT Id, c2g__HomeValue__c, Revised_Projection__c, ' + 
            'Q1_Projection__c, Q2_Projection__c, Q3_Projection__c, Q4_Projection__c ' + 
			'FROM c2g__ReportingBalance__c WHERE c2g__Type__c = :type ' + 
            'AND c2g__YearNumber__c = :yearAsInteger ' + 
            'AND c2g__GeneralLedgerAccount__r.c2g__Type__c = :profitAndLoss ' +
			'AND c2g__OwnerCompany__r.Key__c = :company';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c> scope) { 
        
        List<c2g__ReportingBalance__c> forUpdate = new List<c2g__ReportingBalance__c>();
        for( c2g__ReportingBalance__c someBalance : scope) {
            
            // A revised projection was provided. Update the quarterly tracking to reflect the revision, as well as the home value.
            if( someBalance.Revised_Projection__c != null && someBalance.Revised_Projection__c <> someBalance.c2g__HomeValue__c) {
                someBalance.c2g__HomeValue__c = someBalance.Revised_Projection__c;
                if (period.contains('03'))
	                someBalance.Q1_Projection__c = someBalance.Revised_Projection__c;
                if (period.contains('06'))
	                someBalance.Q2_Projection__c = someBalance.Revised_Projection__c;                
                if (period.contains('09'))
	                someBalance.Q3_Projection__c = someBalance.Revised_Projection__c;                
                if (period.contains('12'))
	                someBalance.Q4_Projection__c = someBalance.Revised_Projection__c;                
            }
            // No revision was made. No change to home value needed. Stash the existing value in a tracking field.
            else {
                if (period.contains('03'))
	                someBalance.Q1_Projection__c = someBalance.c2g__HomeValue__c;
                if (period.contains('06'))
	                someBalance.Q2_Projection__c = someBalance.c2g__HomeValue__c;             
                if (period.contains('09'))
	                someBalance.Q3_Projection__c = someBalance.c2g__HomeValue__c;              
                if (period.contains('12'))
	                someBalance.Q4_Projection__c = someBalance.c2g__HomeValue__c;
            }
            forUpdate.add(someBalance);
        }
		update forUpdate;
    }

    global void finish(Database.BatchableContext bc) { }    
}