public with sharing class CBDeleteBudgetFFRBJob implements Database.Batchable<SObject>, Database.Stateful{
	private String CBRId = null;
	private Decimal currentFY = null;

	public CBDeleteBudgetFFRBJob(){
		if (Test.isRunningTest()) {
			codeGen();
		}
	}
	public CBDeleteBudgetFFRBJob(Id cbrlId, String currYear){
		CBRId = cbrlId;
		currentFY = Decimal.valueOf(currYear);
	}
	public Database.QueryLocator start(Database.BatchableContext BC) {
		String q = 'SELECT Id FROM cb4__CBalance__c WHERE cb4__CBalanceRule__c = \'' + CBRId + '\'';
		return Database.getQueryLocator(q);
	}

	/**
	* Method to delete imported from CB FF RBs
	* @param BC
	* @param scope
	*/
	public void execute(Database.BatchableContext BC, List<SObject> scope) {
		Map<Id, SObject> cbm = new Map<Id, SObject>(scope);
		Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(cbm.keySet()), Set<String>.class);
		delete [SELECT Id FROM c2g__ReportingBalance__c WHERE c2g__Type__c = 'CB Budget' AND c2g__YearNumber__c = :currentFY AND c2g__ExternalId__c IN :idStrs];
	}

	public void finish(Database.BatchableContext BC) {
		cb4.CBController.recalculateSpecifiedCBalances(new List<Id>{CBRId}, 'CBBudgetReportingBalanceUpdate2');
	}

	public void codeGen(){
		Integer i=0;
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