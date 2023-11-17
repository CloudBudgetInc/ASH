@isTest(SeeAllData=true)
public class JournalValidatorAshRcScheduledTest {

    static testMethod void testBadBatch() {
        
		FfaDataProvider provider = FfaDataProvider.getInstance();
       	c2g__codaPeriod__c period = provider.getPeriod('ASHRC', '202402');
       	String journalStatus = 'In Progress';
        
        c2g__codaJournal__c someJournal = new c2g__codaJournal__c();
        someJournal.c2g__OwnerCompany__c = provider.getCompany('ASHRC');
        someJournal.c2g__JournalStatus__c = 'In Progress';
        someJournal.c2g__Period__c = period.Id;
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
        
        Test.startTest();
        JournalValidatorAshRcScheduled jvars = new JournalValidatorAshRcScheduled();
        Id jobid = Database.executeBatch(jvars,1);
        Test.stopTest();
        
        List<c2g__codaJournalLineItem__c> badLines = [SELECT Id FROM c2g__codaJournalLineItem__c  
        	WHERE c2g__Journal__r.c2g__JournalDescription__c = 'Test Journal 999' AND Invalid__c = true];
        System.assertEquals(badLines.size(), 1);
    }
    
    static testMethod void testGoodBatch() {
        
		FfaDataProvider provider = FfaDataProvider.getInstance();
       	c2g__codaPeriod__c period = provider.getPeriod('ASHRC', '202402');
       	String journalStatus = 'In Progress';
        
        c2g__codaJournal__c someJournal = new c2g__codaJournal__c();
        someJournal.c2g__OwnerCompany__c = provider.getCompany('ASHRC');       
        someJournal.c2g__JournalStatus__c = 'In Progress';
        someJournal.c2g__Period__c = period.Id;
        someJournal.c2g__JournalDescription__c = 'Test Journal 998';
        insert someJournal;
        
        c2g__codaJournalLineItem__c someLine = new c2g__codaJournalLineItem__c();
        someLine.c2g__Journal__c = someJournal.Id;
        someLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        someLine.c2g__Dimension1__c = provider.getDimension1('112');
        someLine.c2g__Dimension2__c = provider.getDimension2('459');
        someLine.c2g__Dimension3__c = provider.getDimension3('000');
        someLine.c2g__Dimension4__c = provider.getDimension4('00');        
        someLine.c2g__LineType__c = 'General Ledger Account';
        someLine.c2g__LineDescription__c = 'Test Entry';
        someLine.c2g__Value__c = 100;
        insert someLine;
        
        Test.startTest();
        JournalValidatorAshRcScheduled jvas = new JournalValidatorAshRcScheduled();
        Id jobid = Database.executeBatch(jvas,1);
        Test.stopTest();
        
        List<c2g__codaJournalLineItem__c> goodLines = [SELECT Id FROM c2g__codaJournalLineItem__c  
        	WHERE c2g__Journal__r.c2g__JournalDescription__c = 'Test Journal 998' AND Invalid__c = false];
        System.assertEquals(1, goodLines.size());
    }    
    
    static testMethod void testScheduler() { 
        Test.startTest();
		System.schedule('JournalValidatorAshRcScheduled', '0 0 1 * * ?', new JournalValidatorAshRcScheduled());
        Test.stopTest();
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob WHERE ApexClass.Name = 'JournalValidatorAshRcScheduled' 
        	AND JobType = 'BatchApex' AND Status = 'Queued'];        
        System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);
        System.assertEquals('Queued', batchJobs[0].Status, 'Job planned with an unexpected status.');
    }
}