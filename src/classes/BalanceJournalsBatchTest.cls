@isTest(SeeAllData=true)
public class BalanceJournalsBatchTest {

    static testMethod void mainTest() {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        
        c2g__codaJournal__c someJournal = new c2g__codaJournal__c();
        someJournal.c2g__JournalStatus__c = 'In Progress';
        someJournal.c2g__OwnerCompany__c = provider.getCompany('ASH');
        someJournal.Flag_for_Balance__c = true;
        someJournal.c2g__JournalDescription__c = 'Test Journal';
        insert someJournal;
        
        c2g__codaJournalLineItem__c someLine = new c2g__codaJournalLineItem__c();
        someLine.c2g__Journal__c = someJournal.Id;
        someLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        someLine.c2g__LineType__c = 'General Ledger Account';
        someLine.c2g__LineDescription__c = 'Test Entry';
        someLine.c2g__Value__c = 100;
        insert someLine;
        
        Test.startTest();
        BalanceJournalsBatch bjb = new BalanceJournalsBatch();
        Id jobid = Database.executeBatch(bjb,1);
        Test.stopTest();
        
        c2g__codaJournal__c testJournal = [SELECT Id, c2g__Total__c FROM c2g__codaJournal__c 
                                          WHERE c2g__JournalDescription__c = 'Test Journal'];
        System.assertEquals(testJournal.c2g__Total__c,0);
        
    }    
}