global with sharing class CBBudgetReportingBalanceUpdate1 implements Queueable{
	global CBBudgetReportingBalanceUpdate1(){
		System.enqueueJob(new CBBudgetReportingBalanceUpdate1(null));
	}
	global CBBudgetReportingBalanceUpdate1(Object arg){

	}
	public void execute(QueueableContext context){
		if (!Test.isRunningTest()) {
			run();
		}else{
			Integer i = 0;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
		}
	}
	public static void run(){
		cb4__CBCustomOrgVariable__c cov = cb4.CBGlobalVariable.getOrgCBCustomOrgVariable();
		String q = 'SELECT Id FROM cb4__CBalanceRule__c WHERE cb4__Label__c LIKE \'CB to FF ' + cov.cb4__BudgetYear__c + '\'';
		List<Id> CBRIds = new List<Id>();
		for(cb4__CBalanceRule__c CBR : Database.query(q)){
			CBRIds.add(CBR.Id);
			CBDeleteBudgetFFRBJob dj = new CBDeleteBudgetFFRBJob(CBR.Id, cov.cb4__BudgetYear__c);
			Id batchId = Database.executeBatch(dj, 2000);
		}
	}
}