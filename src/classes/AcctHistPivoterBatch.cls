global class AcctHistPivoterBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);
		String query = 'SELECT Id, Acct__c, Sub__c, CmpnyId__c , Fiscal__c, PtdBal00__c, PtdBal01__c, ' + 
        'PtdBal02__c, PtdBal03__c, PtdBal04__c, PtdBal05__c, PtdBal06__c, PtdBal07__c, PtdBal08__c, ' + 
        'PtdBal09__c, PtdBal10__c, PtdBal11__c ' + 
        'FROM AcctHistImport__c WHERE CmpnyId__c = :companyKey';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<AcctHistImport__c> scope) {
        
        List<AcctHistImportPivot__c> forInsert = new List<AcctHistImportPivot__c>();
		
		for(AcctHistImport__c acctHist : scope) {
			AcctHistImportPivot__c somePivot1 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c, Acct__c = acctHist.Acct__c, 
                    Sub__c = acctHist.Sub__c, Amount__c  = acctHist.PtdBal00__c, PerPost__c = acctHist.Fiscal__c + '01');
			AcctHistImportPivot__c somePivot2 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                    Amount__c  = acctHist.PtdBal01__c, PerPost__c = acctHist.Fiscal__c + '02');
			AcctHistImportPivot__c somePivot3 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                	Amount__c  = acctHist.PtdBal02__c, PerPost__c = acctHist.Fiscal__c + '03');
			AcctHistImportPivot__c somePivot4 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                    Amount__c  = acctHist.PtdBal03__c, PerPost__c = acctHist.Fiscal__c + '04');  
			AcctHistImportPivot__c somePivot5 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                	Amount__c  = acctHist.PtdBal04__c, PerPost__c = acctHist.Fiscal__c + '05');
			AcctHistImportPivot__c somePivot6 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                    Amount__c  = acctHist.PtdBal05__c, PerPost__c = acctHist.Fiscal__c + '06');
			AcctHistImportPivot__c somePivot7 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                	Amount__c  = acctHist.PtdBal06__c, PerPost__c = acctHist.Fiscal__c + '07');
			AcctHistImportPivot__c somePivot8 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                    Amount__c  = acctHist.PtdBal07__c, PerPost__c = acctHist.Fiscal__c + '08'); 
            AcctHistImportPivot__c somePivot9 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                	Amount__c  = acctHist.PtdBal08__c, PerPost__c = acctHist.Fiscal__c + '09');
			AcctHistImportPivot__c somePivot10 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                    Amount__c  = acctHist.PtdBal09__c, PerPost__c = acctHist.Fiscal__c + '10');
			AcctHistImportPivot__c somePivot11 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                	Amount__c  = acctHist.PtdBal10__c, PerPost__c = acctHist.Fiscal__c + '11');
			AcctHistImportPivot__c somePivot12 = 
                new AcctHistImportPivot__c(Company__c = acctHist.CmpnyId__c,Acct__c = acctHist.Acct__c, Sub__c = acctHist.Sub__c, 
                    Amount__c  = acctHist.PtdBal11__c, PerPost__c = acctHist.Fiscal__c + '12'); 
            forInsert.add(somePivot1);
            forInsert.add(somePivot2);
            forInsert.add(somePivot3);
            forInsert.add(somePivot4);
            forInsert.add(somePivot5);
            forInsert.add(somePivot6);
            forInsert.add(somePivot7);
            forInsert.add(somePivot8);
            forInsert.add(somePivot9);
            forInsert.add(somePivot10);
            forInsert.add(somePivot11);
            forInsert.add(somePivot12);            
        }
        
        insert forInsert;
    }
    
    public void finish(Database.BatchableContext bc) { }
    
}