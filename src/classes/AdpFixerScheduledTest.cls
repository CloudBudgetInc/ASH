@isTest(SeeAllData=true)
public class AdpFixerScheduledTest {

     public static testmethod void testBatchable() {
         
        FfaDataProvider provider = FfaDataProvider.getInstance();
        
        c2g__codaJournal__c someJournal = new c2g__codaJournal__c();
        someJournal.c2g__JournalStatus__c = 'In Progress';
        someJournal.c2g__OwnerCompany__c = provider.getCompany('ASH');
        someJournal.c2g__JournalDescription__c = 'ADP Payroll Integration';
        insert someJournal;
        
        c2g__codaJournalLineItem__c someLine = new c2g__codaJournalLineItem__c();
        someLine.c2g__Journal__c = someJournal.Id;
        someLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('9035');
        someLine.c2g__Dimension1__c = provider.getDimension1('302');
        someLine.c2g__Dimension2__c = provider.getDimension2('392');
        someLine.c2g__Dimension3__c = provider.getDimension3('000');
        someLine.c2g__Dimension4__c = provider.getDimension4('00');        
        someLine.c2g__LineType__c = 'General Ledger Account';
        someLine.c2g__LineDescription__c = 'Test Entry';
        someLine.c2g__Value__c = 123.45;
        insert someLine;
         
        c2g__codaJournalLineItem__c anotherLine = new c2g__codaJournalLineItem__c();
        anotherLine.c2g__Journal__c = someJournal.Id;
        anotherLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('9030');
        anotherLine.c2g__Dimension1__c = provider.getDimension1('302');
        anotherLine.c2g__Dimension2__c = provider.getDimension2('450');
        anotherLine.c2g__Dimension3__c = provider.getDimension3('000');
        anotherLine.c2g__Dimension4__c = provider.getDimension4('00');        
        anotherLine.c2g__LineType__c = 'General Ledger Account';
        anotherLine.c2g__LineDescription__c = 'Test Entry';
        anotherLine.c2g__Value__c = 987.34;
        insert anotherLine;
         
        Test.StartTest();
        Database.executeBatch(new AdpFixerScheduled());
        Test.StopTest();  
         
		c2g__codaJournalLineItem__c testJournalLine = [SELECT Id, c2g__LineType__c, c2g__DestinationLineType__c
                                                      FROM c2g__codaJournalLineItem__c 
                                                      WHERE c2g__Value__c = 123.45 and CreatedDate = TODAY];
		c2g__codaJournalLineItem__c otherTestJournalLine = [SELECT Id, c2g__LineType__c, c2g__DestinationLineType__c
                                                      FROM c2g__codaJournalLineItem__c 
                                                      WHERE c2g__Value__c = 987.34 and CreatedDate = TODAY];
         
        System.assertEquals('Intercompany', testJournalLine.c2g__LineType__c);
		System.assertEquals('General Ledger Account', testJournalLine.c2g__DestinationLineType__c );
        System.assertEquals('Intercompany', otherTestJournalLine.c2g__LineType__c);
		System.assertEquals('General Ledger Account', otherTestJournalLine.c2g__DestinationLineType__c );
     }

    private static testmethod void testSchedulable() { 
        Test.startTest();
		System.schedule('Delete Logs Schedulable', '0 0 1 * * ?', new AdpFixerScheduled());
        Test.stopTest();
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE ApexClass.Name = 'AdpFixerScheduled' AND JobType = 'BatchApex'];        
        System.assertEquals(1, batchJobs.size(), 'Unexpected number of batch jobs ran: ' + batchJobs);
        System.assertEquals('Queued', batchJobs[0].Status, 'Job planned with an unexpected status.');
    }
}