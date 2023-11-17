global class BudgetStagerImportBatch implements Database.Batchable<sObject> {
    
    String batchId;
    
    public BudgetStagerImportBatch(String batchId) {
        this.batchId = batchId;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

		String query = 'SELECT Id, Amount__c, Company__c, Accounting_Code__c , Period__c ' +
        'FROM Budget_Stager_Import__c ' + 
        'WHERE Processed__c = false';
		return Database.getQueryLocator(query);
	}
	
    global void execute(Database.BatchableContext BC, List<Budget_Stager_Import__c> scope) { 
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
    	
        List<Budget_Stager_Import__c> knockdowns = new List<Budget_Stager_Import__c>();
        List<Personnel_Budget_Stager__c> forInsert = new List<Personnel_Budget_Stager__c>();
        
        for( Budget_Stager_Import__c someBudgetImport : scope ) {
            Personnel_Budget_Stager__c someStager = new Personnel_Budget_Stager__c ();
            
            someStager.Accounting_Company__c = provider.getCompany(someBudgetImport.Company__c);
            String accountingCode = someBudgetImport.Accounting_Code__c;
			someStager.General_Ledger_Account__c = provider.getGlaCode(accountingCode.substring(0,4));
            someStager.Dimension_1__c = provider.getDimension1(accountingCode.substring(5,8));
            someStager.Dimension_2__c = provider.getDimension2(accountingCode.substring(9,12));
            someStager.Dimension_3__c = provider.getDimension3(accountingCode.substring(13,16));
            someStager.Dimension_4__c = provider.getDimension4(accountingCode.substring(17,19));
            someStager.Amount__c = Decimal.valueOf(someBudgetImport.Amount__c);
            someStager.Period__c = someBudgetImport.Period__c;
            someStager.Personnel_Budget_Batch__c = batchId;
			forInsert.add(someStager);
            someBudgetImport.Processed__c = true;
            knockdowns.add(someBudgetImport);
        }
        insert forInsert;
        update knockdowns;
    }
    
    public void finish(Database.BatchableContext bc) { }    
}