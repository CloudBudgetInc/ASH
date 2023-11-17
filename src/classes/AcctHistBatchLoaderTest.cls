@isTest(seeAllData=true)
public class AcctHistBatchLoaderTest {

	public static testMethod void testAcctHistBatchLoad() {
        AcctHistImportPivot__c someAcctHistPivot = new AcctHistImportPivot__c();
        someAcctHistPivot.Acct__c = '7020';
        someAcctHistPivot.Amount__c = Decimal.valueOf('20392.00');
        someAcctHistPivot.Company__c   = 'ASH';
        someAcctHistPivot.PerPost__c  = '202103';
        someAcctHistPivot.Sub__c = '11235900000';
        someAcctHistPivot.Processed__c = false;
        insert someAcctHistPivot;
        Test.startTest();
        AcctHistBatchLoader ahbl = new AcctHistBatchLoader();
        Id jobid = Database.executeBatch(ahbl,1);
        Test.stopTest();
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someCompany = provider.getCompany('ASH');
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202103');
        
        c2g__codaJournal__c testJournal = [SELECT Id, c2g__OwnerCompany__c, c2g__Period__c, 
                                           	c2g__Debits__c, c2g__Credits__c, c2g__JournalDate__c, c2g__Type__c 
                                           	FROM c2g__codaJournal__c 
              								WHERE Migration__c = true AND CreatedDate = TODAY];
        System.assertEquals(someCompany, testJournal.c2g__OwnerCompany__c); // Verify Company
        System.assertEquals(somePeriod.Id, testJournal.c2g__Period__c); // Verify Period
        System.assertEquals(0.00, testJournal.c2g__Debits__c); // Verify Debits
        System.assertEquals(-20392.00, testJournal.c2g__Credits__c); // Verify Credits
        System.assertEquals(somePeriod.c2g__EndDate__c, testJournal.c2g__JournalDate__c); // verify end date
        System.assertEquals('Manual Journal', testJournal.c2g__Type__c); 
        //System.assertEquals(someTxImport.Id, actual);
    }
}