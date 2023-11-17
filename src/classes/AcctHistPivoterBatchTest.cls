@isTest(seeAllData=true)
public class AcctHistPivoterBatchTest {
    
	public static testMethod void testAcctHistPivoterBatch() {
     
		AcctHistImport__c someAcctHistImport = new AcctHistImport__c();
        someAcctHistImport.Acct__c = '2999';
        someAcctHistImport.Sub__c = '10000000000';
        someAcctHistImport.CmpnyId__c = 'ASH';
        someAcctHistImport.Fiscal__c = '2015';
        someAcctHistImport.PtdBal00__c = 100000.00;
        someAcctHistImport.PtdBal01__c = 200000.00;
        someAcctHistImport.PtdBal02__c = 300000.00;
        someAcctHistImport.PtdBal03__c = 400000.00;
        someAcctHistImport.PtdBal04__c = 500000.00;
        someAcctHistImport.PtdBal05__c = 600000.00; 
        someAcctHistImport.PtdBal06__c = 700000.00; 
        someAcctHistImport.PtdBal07__c = 800000.00;
        someAcctHistImport.PtdBal08__c = 900000.00;
        someAcctHistImport.PtdBal09__c = 100000.00;
        someAcctHistImport.PtdBal10__c = 200000.00;
        someAcctHistImport.PtdBal11__c = 300000.00;
        someAcctHistImport.Processed__c = false;
        insert someAcctHistImport;
        
        Test.startTest();
        AcctHistPivoterBatch ahpb = new AcctHistPivoterBatch();
        Id jobid = Database.executeBatch(ahpb,1);
        Test.stopTest();
        
        AcctHistImportPivot__c testPivot = [SELECT Id, Company__c, Acct__c, Sub__c, Amount__c 
                                            FROM AcctHistImportPivot__c 
                                            WHERE PerPost__c = '201501'];
        System.assertEquals(testPivot.Company__c, 'ASH');
        System.assertEquals(testPivot.Acct__c, '2999');
		System.assertEquals(testPivot.Sub__c, '10000000000');
		System.assertEquals(testPivot.Amount__c, 100000.00);        
    }

}