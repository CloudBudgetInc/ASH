global class MonthCloseBatch implements Database.Batchable<sObject> {

    String company = 'ASH';
    String period = '';
    public MonthCloseBatch(String company, String period) {
        this.company = company;
        this.period = period;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

	    List<Month_Close__c> params = Month_Close__c.getall().values();
        String type = String.valueOf(params[0].Type__c);
		String profitAndLoss = 'Profit and Loss';
        String query = 'SELECT c2g__GeneralLedgerAccount__r.Name, c2g__Dimension1__c, c2g__Dimension2__c, ' + 
        'c2g__Dimension3__c, c2g__Dimension4__c, c2g__DualValue__c ' + 
        'FROM c2g__ReportingBalance__c ' +
        'WHERE c2g__Type__c = :type AND ' + 
        'c2g__GeneralLedgerAccount__r.c2g__Type__c = :profitAndLoss AND ' +
        'c2g__Period__r.PerPost__c = :period AND ' +
        'c2g__OwnerCompany__r.Key__c = :company';
		return Database.getQueryLocator(query);
	}
	    
	global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c> scope) {

   		FfaDataProvider provider = FfaDataProvider.getInstance();    
        Id thisCompanyId = provider.getCompany(company);
        
		List<c2g__codaJournalLineItem__c> forInsert = new List<c2g__codaJournalLineItem__c>();
        
        c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
        thisJournal.c2g__Type__c = 'Manual Journal';
        thisJournal.c2g__OwnerCompany__c = thisCompanyId;
        thisJournal.c2g__DeriveCurrency__c = true;
        thisJournal.c2g__DerivePeriod__c = false;
        c2g__codaPeriod__c somePeriod = provider.getPeriod(company, period);
        thisJournal.c2g__Period__c = somePeriod.Id;
        thisJournal.c2g__JournalDate__c = somePeriod.c2g__StartDate__c;
        thisJournal.c2g__JournalDescription__c = '2999 Transactions - ' + somePeriod.c2g__StartDate__c.format();
        insert thisJournal;
        
        Id twenty999 = provider.getGlaCode('2999');
        Id ninety997 = provider.getGlaCode('9997');
        
        //Decimal total = 0.00;
		for(c2g__ReportingBalance__c repBalance : scope) {
            
            c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();   
            journalLine.c2g__Journal__c = thisJournal.Id;
            Decimal value = repBalance.c2g__DualValue__c ;
		    journalLine.c2g__GeneralLedgerAccount__c = twenty999;
		    journalLine.c2g__Dimension1__c = repBalance.c2g__Dimension1__c;
		    journalLine.c2g__Dimension2__c = repBalance.c2g__Dimension2__c;
		    journalLine.c2g__Dimension3__c = repBalance.c2g__Dimension3__c;
		    journalLine.c2g__Dimension4__c = repBalance.c2g__Dimension4__c;
		    journalLine.c2g__Value__c = value;
            //total =+ value;
	    	journalLine.c2g__LineType__c = 'General Ledger Account';            
		    journalLine.c2g__LineDescription__c = '2999 summary - ' + repBalance.c2g__GeneralLedgerAccount__r.Name;

            forInsert.add(journalLine);
        }
        insert forInsert;
        
        c2g__codaJournal__c outputJournal = [SELECT c2g__Total__c from c2g__codaJournal__c 
                                           WHERE Id = :thisJournal.Id LIMIT 1];
        
        c2g__codaJournalLineItem__c balancingLine = new c2g__codaJournalLineItem__c();   
        balancingLine.c2g__Journal__c = thisJournal.Id;
        balancingLine.c2g__GeneralLedgerAccount__c = ninety997;
        balancingLine.c2g__Value__c = (outputJournal.c2g__Total__c * -1);
        balancingLine.c2g__LineType__c = 'General Ledger Account';        
        balancingLine.c2g__LineDescription__c = 'Balancing entry'; 
        insert balancingLine;
    }    
    
    public void finish(Database.BatchableContext bc) { }
}