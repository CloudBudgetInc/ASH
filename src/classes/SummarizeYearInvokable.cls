public class SummarizeYearInvokable {

  	@InvocableMethod(label='Summarize year' 
                   description='Move year-long balance sheet activity to a journal for rollover purposes.' 
                   category='Year End') 
    public static void invokeSummarizeYear(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        String company = nestedParams.get(0);
        String sourcePeriod = nestedParams.get(1);
        String targetPeriod = nestedParams.get(2);
        String type = nestedParams.get(3);
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id companyId = provider.getCompany(company);
        c2g__codaPeriod__c closingPeriod = provider.getPeriod(company, sourcePeriod);
        c2g__codaPeriod__c openingPeriod = provider.getPeriod(company, targetPeriod);
        Id periodId = closingPeriod.Id;
        Decimal periodYear = closingPeriod.Fiscal_Year__c;
        String accountType = 'Balance Sheet';
        String balanceType = 'Actual';
        List<String> disincludedGeneralLedgers = new List<String>();
        disincludedGeneralLedgers.add('2999');
        disincludedGeneralLedgers.add('9997'); 
        String twentyNineNinetyNine = '2999';
        
        c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
        thisJournal.c2g__Type__c = 'Manual Journal';
        thisJournal.c2g__OwnerCompany__c = companyId;
        thisJournal.c2g__DeriveCurrency__c = true;
        thisJournal.c2g__DerivePeriod__c = false;
        thisJournal.c2g__Period__c = openingPeriod.Id;
        thisJournal.c2g__JournalDate__c = openingPeriod.c2g__StartDate__c;
        thisJournal.c2g__JournalDescription__c = 'Rollover Balances - ' + openingPeriod.c2g__StartDate__c.format();
        insert thisJournal;        
        
        List<AggregateResult> mainResults = [SELECT c2g__GeneralLedgerAccount__c, c2g__Dimension1__c, 
        	c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, SUM(c2g__HomeValue__c) Total 
			FROM c2g__ReportingBalance__c 
			WHERE c2g__Period__r.Fiscal_Year__c = :periodYear 
			AND c2g__OwnerCompany__r.Key__c = :company 
			AND c2g__GeneralLedgerAccount__r.c2g__Type__c = :accountType 
			AND c2g__Type__c = :balanceType 
			AND c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c NOT IN :disincludedGeneralLedgers  
            GROUP BY c2g__GeneralLedgerAccount__c, c2g__Dimension1__c, c2g__Dimension2__c, c2g__Dimension3__c, 
			c2g__Dimension4__c];
            
        System.debug('Size: ' + mainResults.size());
        
		List<c2g__codaJournalLineItem__c> forInsert = new List<c2g__codaJournalLineItem__c>(); 
        for( AggregateResult someResult : mainResults ) {
            
            c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();   
            journalLine.c2g__Journal__c = thisJournal.Id;
		    journalLine.c2g__GeneralLedgerAccount__c = (Id) someResult.get('c2g__GeneralLedgerAccount__c');
		    journalLine.c2g__Dimension1__c = (Id) someResult.get('c2g__Dimension1__c');
		    journalLine.c2g__Dimension2__c = (Id) someResult.get('c2g__Dimension2__c');
		    journalLine.c2g__Dimension3__c = (Id) someResult.get('c2g__Dimension3__c');
		    journalLine.c2g__Dimension4__c = (Id) someResult.get('c2g__Dimension4__c');
		    journalLine.c2g__Value__c = (Decimal) someResult.get('Total');
		    journalLine.c2g__LineDescription__c = 'Balance rollover';     
            journalLine.c2g__LineType__c = 'General Ledger Account';
            forInsert.add(journalLine);             
        }
        
        List<AggregateResult> secondaryResults = 
            [SELECT c2g__GeneralLedgerAccount__c, SUM(c2g__HomeValue__c) Total 
			FROM c2g__ReportingBalance__c 
			WHERE c2g__Period__r.Fiscal_Year__c = :periodYear 
			AND c2g__OwnerCompany__r.Key__c = :company 
			AND c2g__GeneralLedgerAccount__r.c2g__Type__c = :accountType 
			AND c2g__Type__c = :balanceType 
			AND c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c = :twentyNineNinetyNine  
            GROUP BY c2g__GeneralLedgerAccount__c]; 
        
        AggregateResult secondaryResult = secondaryResults.get(0);
        
        c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();   
        journalLine.c2g__Journal__c = thisJournal.Id;
        journalLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('2874');
        journalLine.c2g__Dimension1__c = provider.getDimension1('100');
        journalLine.c2g__Dimension2__c = provider.getDimension2('000');
        journalLine.c2g__Dimension3__c = provider.getDimension3('000');
        journalLine.c2g__Dimension4__c = provider.getDimension4('00');
        journalLine.c2g__Value__c = (Decimal) secondaryResult.get('Total');
        journalLine.c2g__LineDescription__c = '2999 rollover';
        journalLine.c2g__LineType__c = 'General Ledger Account';
        forInsert.add(journalLine);         
        
        insert forInsert;
    }
}