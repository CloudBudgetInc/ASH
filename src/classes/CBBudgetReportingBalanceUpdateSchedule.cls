global with sharing class CBBudgetReportingBalanceUpdateSchedule implements Schedulable{
	global void execute(SchedulableContext SC) {
		cb4__CBCustomOrgVariable__c cov = cb4.CBGlobalVariable.getOrgCBCustomOrgVariable();
		cov.cb4__LastUpdate__c = System.now();
		String status = cb4.CBGlobalVariable.updateCBCustomOrgVariable(cov);
		if (!Test.isRunningTest()) {
			CBBudgetReportingBalanceUpdate1 runPuff = new CBBudgetReportingBalanceUpdate1();
		}
	}
}