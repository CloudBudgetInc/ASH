global class ReconciliationsPatchBatch implements Database.Batchable<sObject> {

    String company = '';
    String period = '';
    String account = '';
    public ReconciliationsPatchBatch(String company, String period, String account) {
        this.company = company;
        this.account = account;
        this.period = period;
    }    
    
    /**
     * Reconciliation of AR accounts mostly deals with Personify transactions, but not exclusively.
     * In order to full reconcile, we need to 'patch' our Personify transactions with journal entries 
     * that have been entered. This class need not be run each month, but can be run selectively when 
     * a particular account has a balance that doesn't match the total of our Personify transactions.
     */    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
	    FfaDataProvider provider = FfaDataProvider.getInstance();   
        Id companyId = provider.getCompany(company);  
        c2g__codaPeriod__c reconciliationPeriod = provider.getPeriod(company, period);
        Id periodId = reconciliationPeriod.Id;
        String personifyKey = '%Personify Transaction Import%';
        
        // Search for any non-Personify transactions. 
        // Dependent on a consistent naming convention from the Personify import process.
		String query = 'SELECT Id, c2g__HomeValue__c, c2g__LineDescription__c, c2g__TransactionDate__c, ' + 
            'Account_Subaccount__c, c2g__Transaction__r.c2g__DocumentNumber__c ' + 
            'FROM c2g__codaTransactionLineItem__c ' + 
            'WHERE c2g__Transaction__r.c2g__Period__c = :periodId AND ' +            
        	'c2g__Transaction__r.c2g__OwnerCompany__c = :companyId AND ' +
            'c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c = :account AND (NOT ' + 
            'c2g__Transaction__r.c2g__DocumentDescription__c LIKE :personifyKey)';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<c2g__codaTransactionLineItem__c> scope) {    
    
        List<Personify_Transaction__c> forInsert = new List<Personify_Transaction__c>();
        
        for(c2g__codaTransactionLineItem__c someLineItem : scope) {
            Personify_Transaction__c patch = new Personify_Transaction__c();
            patch.Internal_Account__c = someLineItem.Account_Subaccount__c;
            patch.Transaction_Amount__c = String.valueOf(Math.abs(someLineItem.c2g__HomeValue__c));            
            patch.CreditDebit__c = someLineItem.c2g__HomeValue__c > 0 ? 'D' : 'C';
            patch.Effective_Date__c = someLineItem.c2g__TransactionDate__c;
            patch.Post_Date__c = someLineItem.c2g__TransactionDate__c;
            patch.Period__c = period;
            patch.Bill_To_Name__c = someLineItem.c2g__Transaction__r.c2g__DocumentNumber__c;
            patch.Customer_Id__c = someLineItem.c2g__Transaction__r.c2g__DocumentNumber__c;
            patch.Order_Number__c = someLineItem.c2g__Transaction__r.c2g__DocumentNumber__c;
            patch.Transaction_Type__c = 'GL';
            patch.Company__c = company;
            if(someLineItem.c2g__LineDescription__c != null) {
            	patch.Check_Number__c = someLineItem.c2g__LineDescription__c.left(20);
            	patch.Comments__c = someLineItem.c2g__LineDescription__c.left(20);
            }
            patch.Patch__c = true;
            forInsert.add(patch);
        }
        insert forInsert;
 	}
    
    public void finish(Database.BatchableContext bc) { }
}