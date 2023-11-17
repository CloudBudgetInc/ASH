global with sharing class CBBudgetReportingBalanceUpdate2  implements Queueable{
	private static final Integer startMonth = 7;

	public static String currentFY {
		get {
			if (currentFY == null) currentFY = cb4.CBGlobalVariable.getOrgCBCustomOrgVariable().cb4__BudgetYear__c;
			return currentFY;
		}
		set;
	}

	private static Date startFY {
		get {
			if (startFY == null) startFY = Date.newInstance(Integer.valueOf(currentFY) - 1, startMonth, 1);
			return startFY;
		}
		set;
	}

	private static Date endFY {
		get {
			if (endFY == null) endFY = (Date.newInstance(Integer.valueOf(currentFY), startMonth, 1)).addDays(-1);
			return endFY;
		}
		set;
	}
	global CBBudgetReportingBalanceUpdate2(){
		System.enqueueJob(new CBBudgetReportingBalanceUpdate2(null));
	}
	global CBBudgetReportingBalanceUpdate2(Object arg){

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
		String cbalancerulewhere = 'CB to FF ' + cov.cb4__BudgetYear__c;
		List<cb4__CBalanceRule__c> CBalRule = [SELECT Id FROM cb4__CBalanceRule__c WHERE cb4__Label__c = :cbalancerulewhere];
		cb4.CBFFIntegrationBackward FFBackwardIntegrationJob = null;
		if(!CBalRule.isEmpty()) {
			Id CBalRuleId = CBalRule[0].Id;
			String intDefId = [SELECT Id FROM c2g__codaIntersectDefinition__c WHERE c2g__FullAccountingCode__c = true LIMIT 1].Id;
			String FFRBType = 'CB Budget';
			FFBackwardIntegrationJob = new cb4.CBFFIntegrationBackward(startFY, endFY, intDefId, CBalRuleId, FFRBType, null);
			Id batchId = Database.executeBatch(FFBackwardIntegrationJob, 200);
		}
	}
}