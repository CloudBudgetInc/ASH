global class BalanceImportBatchLoader implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {

	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);                   
		String query = 'SELECT Id, Value__c, Company__c, Account__c, Subaccount__c, PerPost__c ' +
        'FROM Balance_Import__c ' + 
        'WHERE Processed__c = false AND Company__c = :companyKey';
		return Database.getQueryLocator(query);
	}
	
    global void execute(Database.BatchableContext BC, List<Balance_Import__c> scope) { 
    	
	    List<Migration__c> migrationParams = Migration__c.getall().values();
		String companyKey = String.valueOf(migrationParams[0].Company__c);  
        String type = String.valueOf(migrationParams[0].Type__c);  
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        Id companyId = provider.getCompany(companyKey);
        Id intersectDefinition = provider.getIntersectDefinition('Full Accounting');
        
        List<Balance_Import__c> knockdowns = new List<Balance_Import__c>();
        List<c2g__ReportingBalance__c> someReportingBalances = new List<c2g__ReportingBalance__c>();
        for( Balance_Import__c someBalanceImport : scope ) {
            c2g__ReportingBalance__c someReportingBalance = new c2g__ReportingBalance__c();
            String subaccount = someBalanceImport.Subaccount__c;
            someReportingBalance.c2g__OwnerCompany__c = companyId;
			someReportingBalance.c2g__Type__c = type;
			someReportingBalance.c2g__GeneralLedgerAccount__c = provider.getGlaCode(someBalanceImport.Account__c );
            someReportingBalance.c2g__Dimension1__c = provider.getDimension1(subaccount.substring(0,3));
            someReportingBalance.c2g__Dimension2__c = provider.getDimension2(subaccount.substring(3,6));
            someReportingBalance.c2g__Dimension3__c = provider.getDimension3(subaccount.substring(6,9));
            someReportingBalance.c2g__Dimension4__c = provider.getDimension4(subaccount.substring(9,11));
            someReportingBalance.c2g__HomeValue__c = someBalanceImport.Value__c;
            someReportingBalance.c2g__DualValue__c = someBalanceImport.Value__c;
            someReportingBalance.c2g__Period__c = provider.getPeriod(companyKey, someBalanceImport.PerPost__c).Id;
            System.debug(someReportingBalance.c2g__Period__c);
            someReportingBalance.c2g__IntersectDefinition__c = intersectDefinition;
			someReportingBalances.add(someReportingBalance);
            someBalanceImport.Processed__c = true;
            knockdowns.add(someBalanceImport);
        }
        insert someReportingBalances;
        update knockdowns;
    }
    
    public void finish(Database.BatchableContext bc) { }    
}