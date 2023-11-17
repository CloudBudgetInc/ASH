global class SummarizePeriodBatch implements Database.Batchable<sObject> {
    
    String sourcePeriod;
    String company = 'ASH';
    String targetPeriod;
    String type;
    public SummarizePeriodBatch(String company, String sourcePeriod, String targetPeriod, String type) {
        this.company = company;
        this.sourcePeriod = sourcePeriod;
        this.targetPeriod = targetPeriod;
        this.type = type;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id companyId = provider.getCompany(this.company);
        c2g__codaPeriod__c period = provider.getPeriod(this.company, this.sourcePeriod);
        Id periodId = period.Id;
        String accountType = 'Balance Sheet';
		
		String query = 'SELECT c2g__GeneralLedgerAccount__c, c2g__Dimension1__c, c2g__Dimension2__c, c2g__Dimension3__c, ' + 
            'c2g__Dimension4__c, c2g__HomeValue__c FROM c2g__ReportingBalance__c WHERE c2g__Period__c = :periodId and c2g__OwnerCompany__c = :companyId ' + 
            'AND c2g__GeneralLedgerAccount__r.c2g__Type__c = :accountType and c2g__Type__c = :type';
    	return Database.getQueryLocator(query);        
  	}       

    global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c> balances) {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id companyId = provider.getCompany(this.company);
        c2g__codaPeriod__c targetPeriod = provider.getPeriod(this.company, this.targetPeriod);        

        c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
        thisJournal.c2g__Type__c = 'Manual Journal';
        thisJournal.c2g__OwnerCompany__c = companyId;
        thisJournal.c2g__DeriveCurrency__c = true;
        thisJournal.c2g__DerivePeriod__c = false;
        thisJournal.c2g__Period__c = targetPeriod.Id;
        thisJournal.c2g__JournalDate__c = targetPeriod.c2g__StartDate__c;
        thisJournal.Personify_Journal__c = true;
        thisJournal.c2g__JournalDescription__c = 'Rollover Balances - ' + targetPeriod.c2g__StartDate__c.format();
        insert thisJournal;
        
		List<c2g__codaJournalLineItem__c> forInsert = new List<c2g__codaJournalLineItem__c>();        
        for(c2g__ReportingBalance__c someBalance : balances) {
            
            c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();   
            journalLine.c2g__Journal__c = thisJournal.Id;
		    journalLine.c2g__GeneralLedgerAccount__c = someBalance.c2g__GeneralLedgerAccount__c;
		    journalLine.c2g__Dimension1__c = someBalance.c2g__Dimension1__c;
		    journalLine.c2g__Dimension2__c = someBalance.c2g__Dimension2__c;
		    journalLine.c2g__Dimension3__c = someBalance.c2g__Dimension3__c;
		    journalLine.c2g__Dimension4__c = someBalance.c2g__Dimension4__c;
		    journalLine.c2g__Value__c = someBalance.c2g__HomeValue__c;
		    journalLine.c2g__LineDescription__c = 'Balance rollover';     
            journalLine.c2g__LineType__c = 'General Ledger Account';
            forInsert.add(journalLine);    
        }
        insert forInsert;
    }
    
    global void finish(Database.BatchableContext bc) { }
}