@isTest(seeAllData=true)
public class GeneralLedgerTransactionBatchLoaderTest {
    
	public static testMethod void testTransactionImport() {
        Transaction_Import__c someTxImport = new Transaction_Import__c();
        someTxImport.Acct__c = '7020';
        someTxImport.BatNbr__c  = '111850';
        someTxImport.Cmpny__c  = 'ASH';
        someTxImport.DrAmt__c  = Decimal.valueOf('150.00');
       	someTxImport.CrAmt__c  = Decimal.valueOf('0.00');
        someTxImport.ExtRefNbr__c  = '2020';
        someTxImport.PerPost__c  = '202103';
        someTxImport.Sub__c = '11235900000';
        someTxImport.Processed__c = false;
        someTxImport.Transaction_Date__c = Date.valueOf('2020-09-24');
        someTxImport.Transaction_Desc__c = 'DEVI04-Consulting hours from 9';
        insert someTxImport;
        Test.startTest();
        GeneralLedgerTransactionBatchLoader gltbl = new GeneralLedgerTransactionBatchLoader();
        Id jobid = Database.executeBatch(gltbl,1);
        Test.stopTest();
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id someCompany = provider.getCompany('ASH');
        c2g__codaPeriod__c somePeriod = provider.getPeriod('ASH', '202103');
        
        c2g__codaJournal__c testJournal = [SELECT Id, c2g__OwnerCompany__c, c2g__Period__c, 
                                           	c2g__Debits__c, c2g__JournalDate__c, c2g__Type__c 
                                           	FROM c2g__codaJournal__c 
              								WHERE Migration__c = true AND CreatedDate = TODAY];
        System.assertEquals(someCompany, testJournal.c2g__OwnerCompany__c); // Verify Company
        System.assertEquals(somePeriod.Id, testJournal.c2g__Period__c); // Verify Period
        System.assertEquals(150.00, testJournal.c2g__Debits__c); // Verify Debits
        System.assertEquals(somePeriod.c2g__EndDate__c, testJournal.c2g__JournalDate__c); // verify end date
        System.assertEquals('Manual Journal', testJournal.c2g__Type__c); 
        //System.assertEquals(someTxImport.Id, actual);        
    }
}