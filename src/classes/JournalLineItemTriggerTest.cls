@isTest(SeeAllData=true)
public class JournalLineItemTriggerTest {
    
    static testMethod void mainTest() {
    
        FfaDataProvider provider = FfaDataProvider.getInstance();
        
        c2g__codaJournal__c someJournal = new c2g__codaJournal__c();
        someJournal.c2g__JournalStatus__c = 'In Progress';
        someJournal.c2g__OwnerCompany__c = provider.getCompany('ASH');
        someJournal.Flag_for_Balance__c = true;
        someJournal.c2g__JournalDescription__c = 'Test Journal 999';
        insert someJournal;
        
        c2g__codaJournalLineItem__c someLine = new c2g__codaJournalLineItem__c();
        someLine.c2g__Journal__c = someJournal.Id;
        someLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        someLine.c2g__Dimension1__c = provider.getDimension1('100');
        someLine.c2g__Dimension2__c = provider.getDimension2('000');
        someLine.c2g__Dimension3__c = provider.getDimension3('000');
        someLine.c2g__Dimension4__c = provider.getDimension4('00');        
        someLine.c2g__LineType__c = 'General Ledger Account';
        someLine.c2g__LineDescription__c = 'Test Entry';
        someLine.c2g__Value__c = 100;
        insert someLine;
        
        c2g__codaJournalLineItem__c secondLine = new c2g__codaJournalLineItem__c();
        secondLine.c2g__Journal__c = someJournal.Id;
        secondLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        secondLine.c2g__Dimension1__c = provider.getDimension1('112');
        secondLine.c2g__Dimension2__c = provider.getDimension2('359');
        secondLine.c2g__Dimension3__c = provider.getDimension3('000');
        secondLine.c2g__Dimension4__c = provider.getDimension4('00');        
        secondLine.c2g__LineType__c = 'General Ledger Account';
        secondLine.c2g__LineDescription__c = 'Test Entry';
        secondLine.c2g__Value__c = 100;
        insert secondLine;    
        
        c2g__codaJournalLineItem__c thirdLine = new c2g__codaJournalLineItem__c();
        thirdLine.c2g__Journal__c = someJournal.Id;
        thirdLine.c2g__LineType__c = 'Intercompany';
        thirdLine.c2g__DestinationCompany__c = provider.getCompany('ASHRC');
        thirdLine.c2g__DestinationLineType__c = 'General Ledger Account';
        thirdLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        thirdLine.c2g__Dimension1__c = provider.getDimension1('112');
        thirdLine.c2g__Dimension2__c = provider.getDimension2('359');
        thirdLine.c2g__Dimension3__c = provider.getDimension3('000');
        thirdLine.c2g__Dimension4__c = provider.getDimension4('00');
        thirdLine.c2g__LineDescription__c = 'Test Entry';
        thirdLine.c2g__Value__c = 100;
        insert thirdLine;        
        
        c2g__codaJournal__c testJournal = [SELECT Id, Invalid_Lines__c FROM c2g__codaJournal__c 
                                          WHERE c2g__JournalDescription__c = 'Test Journal 999'];
        System.assertEquals(1, testJournal.Invalid_Lines__c);        
        
    }
}