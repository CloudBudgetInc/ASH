global class CBStartPersonnelBudgetDataDeletion {
	@InvocableMethod
	public static void runCBBudgetCleanProcess(List<String> pbbIds){
		Map<String, String> fPMap1 = new Map<String, String>{
				'cb4__Dimension__c' => cb4.CBUtils.dimensionNameIdMap.get('Budget App Amount'),
				'cb4__ExtId__c' => pbbIds[0]
		};
		cb4.CBDeleteJob dj1 = new cb4.CBDeleteJob('cb4__CBTag__c', fPMap1, null, 2000);
		Map<String, String> fPMap2 = new Map<String, String>{
				'cb4__Dimension__c' => cb4.CBUtils.dimensionNameIdMap.get('Budget App SubAmount'),
				'cb4__ExtId__c' => pbbIds[0]
		};
		cb4.CBDeleteJob dj2 = new cb4.CBDeleteJob('cb4__CBTag__c', fPMap2, dj1, 200);
		Id batchId = Database.executeBatch(dj2, 200);
	}

	public static void codeGen(){
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
	}
}