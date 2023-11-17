global class JournalizePrepaidReclass implements Database.Batchable<sObject> {

    String fsrId;
    String periodId;
    
    /**
     * The purpose of this class is to convert a Prepaid Reclass FSR (Finance Support Request) 
     * into a series of journals - effectively, an amortization routine. This process takes a transaction
     * 'off the books' (i.e. the Income Statement) and moves it to the future via prepaid journals.
     * 
     * While technically a batchable/batch class, this is really only going to execute on a single 
     * FSR at a time. We're not going to bulk journalize prepaid reclass FSRs, ever.
     */
    public JournalizePrepaidReclass(String fsrId, String periodId) {
        this.fsrId = fsrId;
        this.periodId = periodId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) { 
        
        String query = 'SELECT Accounting_Company__c, Accounting_Company__r.Key__c, Name, ' + 
            'Description__c, End_Date__c, Start_Date__c, CreatedBy.Name ' + 
            'FROM Finance_Support_Request__c WHERE Id = :fsrId';
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext BC, List<Finance_Support_Request__c> someReclasses) {
        
        Finance_Support_Request__c someReclass = someReclasses.get(0);

        // Query for the related transactions that are to be moved off the income statement to balance sheet.
        String source = 'Source';        
        List<Related_Transaction__c> someRelatedTransactions = 
            [SELECT Id, Amount__c, General_Ledger_Account__c, Line_Description__c, 
             Dimension_1__c, Dimension_2__c, Dimension_3__c, Dimension_4__c 
			FROM Related_Transaction__c WHERE Finance_Support_Request__c = :fsrId AND Type__c = :source];
        
        // We amortize prepaids quarterly, so we divide by 90 to determine how many journals we create.
        // If the start and end dates are in the same month, we need to make sure we create at least 
        // one journal.
        Integer journalCount = (someReclass.Start_Date__c.daysBetween(someReclass.End_Date__c)) / 90;
        if(journalCount == 0) {
            journalCount = 1;
        }
        
        createReversingEntry(someReclass, someRelatedTransactions);
        createPrepaidJournals(someReclass, someRelatedTransactions, journalCount);
    }
    
    /**
     * Takes the expense off the income statement and sends it to balance sheet.
     */
    private void createReversingEntry(Finance_Support_Request__c someReclass, List<Related_Transaction__c> someRelatedTransactions) {

        FfaDataProvider provider = FfaDataProvider.getInstance();

        // Set up the journal header.
        c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
        thisJournal.c2g__Type__c = 'Manual Journal';
        thisJournal.c2g__OwnerCompany__c = someReclass.Accounting_Company__c;
        thisJournal.c2g__DeriveCurrency__c = true;
        thisJournal.c2g__DerivePeriod__c = false;
        thisJournal.c2g__Period__c = periodId;
        thisJournal.c2g__JournalDate__c = Date.today();
        thisJournal.c2g__JournalDescription__c = 'Prepaid Reclass from ' + someReclass.Name;
        thisJournal.c2g__Reference__c = someReclass.Name;
        thisJournal.Finance_Support_Request__c = someReclass.Id;
        insert thisJournal;
        
        // Create a reversing journal line for each of the requested transactions.
        List<c2g__codaJournalLineItem__c> journalLines = new List<c2g__codaJournalLineItem__c>();
        Decimal total = 0.00;
        for(Related_Transaction__c someRelatedTransaction : someRelatedTransactions) {
            c2g__codaJournalLineItem__c someJournalLine = new c2g__codaJournalLineItem__c();
            someJournalLine.c2g__LineDescription__c = someReclass.Description__c + ' (' + someReclass.Name + ')';
            someJournalLine.c2g__LineType__c = 'General Ledger Account';
            someJournalLine.c2g__GeneralLedgerAccount__c = someRelatedTransaction.General_Ledger_Account__c;
            someJournalLine.c2g__Dimension1__c = someRelatedTransaction.Dimension_1__c;
            someJournalLine.c2g__Dimension2__c = someRelatedTransaction.Dimension_2__c;
            someJournalLine.c2g__Dimension3__c = someRelatedTransaction.Dimension_3__c;
            someJournalLine.c2g__Dimension4__c = someRelatedTransaction.Dimension_4__c;
            Decimal creditAmount = (someRelatedTransaction.Amount__c * -1);
            someJournalLine.c2g__Value__c = creditAmount;
            total += creditAmount;
            someJournalLine.c2g__Journal__c = thisJournal.Id;
            journalLines.add(someJournalLine);
        } 
        
        c2g__codaJournalLineItem__c balanceSheetLine = new c2g__codaJournalLineItem__c();
        balanceSheetLine.c2g__LineType__c = 'General Ledger Account';
        balanceSheetLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('1600');
        balanceSheetLine.c2g__LineDescription__c = someReclass.Description__c + ' (' + someReclass.Name + ')';
        balanceSheetLine.c2g__Dimension1__c = provider.getDimension1('100');
        balanceSheetLine.c2g__Dimension2__c = provider.getDimension2('000');
        balanceSheetLine.c2g__Dimension3__c = provider.getDimension3('000');
        balanceSheetLine.c2g__Dimension4__c = provider.getDimension4('00');
        Decimal debitAmount = (total * -1);
        balanceSheetLine.c2g__Value__c = debitAmount;
        balanceSheetLine.c2g__Journal__c = thisJournal.Id;
        journalLines.add(balanceSheetLine);
        insert journalLines;
        
        // Add a reference to this reversing journal to the FSR.
		someReclass.Journal__c = thisJournal.Id;
        someReclass.Journal_Status__c = 'Journalized';
		update someReclass;
    }
    
    /**
     * Creates a series of prepaid journals in the future that pull the expense back to the income statement. 
     * We amortize quarterly, so this would create 4 journals for an expense being sent to prepaid for a full year.
     */
    private void createPrepaidJournals(Finance_Support_Request__c someReclass, List<Related_Transaction__c> someRelatedTransactions, 
                                      Integer journalCount) {
                                          
        FfaDataProvider provider = FfaDataProvider.getInstance();
                                          
		List<c2g__codaJournal__c> prepaidJournals = new List<c2g__codaJournal__c>();
        for(Integer i = 0; i < journalCount; i++) {
            c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
            thisJournal.c2g__Type__c = 'Manual Journal';
            thisJournal.c2g__OwnerCompany__c = someReclass.Accounting_Company__c;
            thisJournal.c2g__DeriveCurrency__c = true;
            thisJournal.c2g__JournalDate__c = someReclass.Start_Date__c.addMonths(i*3);
            thisJournal.c2g__JournalDescription__c = 'Prepaid Reclass - (' + someReclass.Name + ') - ' + someReclass.Start_Date__c.addMonths(i*3).format();
            thisJournal.c2g__Reference__c = someReclass.Name;
            thisJournal.Finance_Support_Request__c = someReclass.Id;
            prepaidJournals.add(thisJournal);
        }
		insert prepaidJournals;
        
        List<c2g__codaJournalLineItem__c> journalLines = new List<c2g__codaJournalLineItem__c>();
        for(c2g__codaJournal__c somePrepaidJournal : prepaidJournals) {
            Decimal total = 0.00;
            for(Related_Transaction__c someRelatedTransaction : someRelatedTransactions) {
               	c2g__codaJournalLineItem__c someJournalLine = new c2g__codaJournalLineItem__c();
                someJournalLine.c2g__LineDescription__c = someReclass.Description__c + ' (' + someReclass.Name + ')';
                someJournalLine.c2g__LineType__c = 'General Ledger Account';
                someJournalLine.c2g__GeneralLedgerAccount__c = someRelatedTransaction.General_Ledger_Account__c;
                someJournalLine.c2g__Dimension1__c = someRelatedTransaction.Dimension_1__c;
                someJournalLine.c2g__Dimension2__c = someRelatedTransaction.Dimension_2__c;
                someJournalLine.c2g__Dimension3__c = someRelatedTransaction.Dimension_3__c;
                someJournalLine.c2g__Dimension4__c = someRelatedTransaction.Dimension_4__c;
                Decimal debitAmount = (someRelatedTransaction.Amount__c) / journalCount;
                someJournalLine.c2g__Value__c = debitAmount.setScale(2);
                total += debitAmount.setScale(2);
                someJournalLine.c2g__Journal__c = somePrepaidJournal.Id;
                journalLines.add(someJournalLine);
            }
            // Add offsetting credit to Balance Sheet account.
            c2g__codaJournalLineItem__c balanceSheetLine = new c2g__codaJournalLineItem__c();
            balanceSheetLine.c2g__LineType__c = 'General Ledger Account';
            balanceSheetLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('1600');
            balanceSheetLine.c2g__LineDescription__c = someReclass.Description__c + ' (' + someReclass.Name + ')';
            balanceSheetLine.c2g__Dimension1__c = provider.getDimension1('100');
            balanceSheetLine.c2g__Dimension2__c = provider.getDimension2('000');
            balanceSheetLine.c2g__Dimension3__c = provider.getDimension3('000');
            balanceSheetLine.c2g__Dimension4__c = provider.getDimension4('00');
            Decimal creditAmount = (total * -1);
            balanceSheetLine.c2g__Value__c = creditAmount;
            balanceSheetLine.c2g__Journal__c = somePrepaidJournal.Id;
            journalLines.add(balanceSheetLine);         
        }
        insert journalLines;                       
    }
    
    global void finish(Database.BatchableContext bc) {}
}