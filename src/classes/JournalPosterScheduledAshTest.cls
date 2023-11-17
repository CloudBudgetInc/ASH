@isTest(SeeAllData=true)
public class JournalPosterScheduledAshTest {

    static testMethod void testAutopost() {
 
	    List<Month_Close__c> params = Month_Close__c.getall().values();
		String companyKey = 'ASH';
       	String perPost = String.valueOf(params[0].PerPost__c);
		FfaDataProvider provider = FfaDataProvider.getInstance();
       	c2g__codaPeriod__c period = provider.getPeriod(companyKey, perPost);
        
        c2g__codaJournal__c someJournal = new c2g__codaJournal__c();
        someJournal.c2g__OwnerCompany__c = provider.getCompany(companyKey);        
        someJournal.c2g__JournalStatus__c = 'In Progress';
        someJournal.Approval_Status__c = 'Approved';
        someJournal.c2g__Period__c = period.Id;
        someJournal.c2g__JournalDescription__c = 'Test Journal 999';
        insert someJournal;
        
        c2g__codaJournalLineItem__c someLine = new c2g__codaJournalLineItem__c();
        someLine.c2g__Journal__c = someJournal.Id;
        someLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('7020');
        someLine.c2g__Dimension1__c = provider.getDimension1('112');
        someLine.c2g__Dimension2__c = provider.getDimension2('359');
        someLine.c2g__Dimension3__c = provider.getDimension3('000');
        someLine.c2g__Dimension4__c = provider.getDimension4('00');        
        someLine.c2g__LineType__c = 'General Ledger Account';
        someLine.c2g__LineDescription__c = 'Test Entry';
        someLine.c2g__Value__c = 100;
        insert someLine;
        
        c2g__codaJournalLineItem__c secondaryLine = new c2g__codaJournalLineItem__c();
        secondaryLine.c2g__Journal__c = someJournal.Id;
        secondaryLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode('1600');
        secondaryLine.c2g__Dimension1__c = provider.getDimension1('100');
        secondaryLine.c2g__Dimension2__c = provider.getDimension2('000');
        secondaryLine.c2g__Dimension3__c = provider.getDimension3('000');
        secondaryLine.c2g__Dimension4__c = provider.getDimension4('00');        
        secondaryLine.c2g__LineType__c = 'General Ledger Account';
        secondaryLine.c2g__LineDescription__c = 'Test Entry';
        secondaryLine.c2g__Value__c = -100;
        insert secondaryLine;        
        
        Test.startTest();
        JournalPosterScheduledAsh jpsa = new JournalPosterScheduledAsh();
        Id jobid = Database.executeBatch(jpsa,1);
        Test.stopTest();
        
        List<c2g__codaJournal__c> journals = [SELECT Id FROM c2g__codaJournal__c 
        	WHERE c2g__JournalDescription__c = 'Test Journal 999' AND Flagged_for_Bulk_Post__c = true];
        System.assertEquals(journals.size(), 1);
    }
}