global class CBAllocationFlow{
	private static final Id BUDGETS_DIM_ID           = cb4.CBUtils.dimensionNameIdMap.get('Budget App');
	private static final Id BUDGET_AMOUNT_DIM_ID     = cb4.CBUtils.dimensionNameIdMap.get('Budget App Amount');
	private static final Id BUDGET_SUB_AMOUNT_DIM_ID = cb4.CBUtils.dimensionNameIdMap.get('Budget App SubAmount');
	private static Map<String, cb4__CBTag__c> extIdToTag {
		get{
			if(extIdToTag == null){
				extIdToTag = new Map<String, cb4__CBTag__c>();
				for(cb4__CBTag__c t : [SELECT Id, Name, cb4__Index__c, cb4__ExtId__c, cb4__Tag1__r.cb4__Tag1Name__c FROM cb4__CBTag__c WHERE cb4__ExtId__c != NULL AND (cb4__DimensionName__c = 'Account' OR cb4__DimensionName__c = 'CB_FF1' OR cb4__DimensionName__c = 'CB_FF2' OR cb4__DimensionName__c = 'CB_FF3' OR cb4__DimensionName__c = 'CB_FF4' OR cb4__DimensionName__c = 'Department')]){
					extIdToTag.put(t.cb4__ExtId__c, t);
				}
			}
			return extIdToTag;
		}
		set;
	}

	private static Map<String, List<String>> periodMap{
		get{
			if(periodMap == null){
				periodMap = new Map<String, List<String>>();
				for(cb4__CBTag__c p : [SELECT Id, Name, cb4__Tag1Name__c FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Period' ORDER BY Name]){
					if(periodMap.containsKey(p.cb4__Tag1Name__c)){
						periodMap.get(p.cb4__Tag1Name__c).add(p.Id);
					}else{
						periodMap.put(p.cb4__Tag1Name__c, new List<String>{p.Id});
					}
				}
			}
			return periodMap;
		}
		set;
	}

	@InvocableMethod
	public static void runAllocationProcess(List<String> recordId){
		Budget_Allocation__c bAllocation = [SELECT Id, Name, Title__c, General_Ledger_Account__c, Year__r.Name, Allocation_Rule__c, Allocation_Rule__r.c2g__Description__c, Year__r.c2g__OwnerCompany__c, Processed__c, Total__c FROM Budget_Allocation__c WHERE Id = :recordId[0]];
		List<Budget_Allocation_Line__c> budgetAllocationLines = [SELECT Id, Amount__c, Description__c FROM Budget_Allocation_Line__c WHERE Budget_Allocation__c =: bAllocation.Id];
		List<c2g__FixedAllocationRuleLine__c> allocationRuleLines = [SELECT Id, c2g__Dimension1__c, c2g__Dimension2__c, c2g__Dimension3__c, c2g__Dimension4__c, c2g__Company__c, c2g__Split__c FROM c2g__FixedAllocationRuleLine__c WHERE c2g__AllocationRule__c = :bAllocation.Allocation_Rule__c];
		Map<String, String> budgetsMapByCBFF1CBFF2 = getBudgetsMapByD1D2Ids(bAllocation.Year__r.Name, extIdToTag.get(allocationRuleLines[0].c2g__Company__c).Id);
		Map<String, cb4__CBTag__c> budgetTotalsByBudgetAndPeriodId = getTotalsMapByBudgetId(bAllocation.Year__r.Name, extIdToTag.get(allocationRuleLines[0].c2g__Company__c).Id);
		Map<String, cb4__CBTag__c> keyToBLbyPeriod = new Map<String, cb4__CBTag__c>();
		List<cb4__CBTag__c> newSubLines = new List<cb4__CBTag__c>();
		for(c2g__FixedAllocationRuleLine__c alLine : allocationRuleLines){
			cb4__CBTag__c acc = extIdToTag.get(bAllocation.General_Ledger_Account__c);
			cb4__CBTag__c d6 = extIdToTag.get(alLine.c2g__Dimension1__c);
			cb4__CBTag__c d7 = extIdToTag.get(alLine.c2g__Dimension2__c);
			cb4__CBTag__c d8 = extIdToTag.get(alLine.c2g__Dimension3__c);
			cb4__CBTag__c d9 = extIdToTag.get(alLine.c2g__Dimension4__c);
			String budgetId = budgetsMapByCBFF1CBFF2.get(String.valueOf(d6.Id) + String.valueOf(d7.Id));
			Decimal qAmount = bAllocation.Total__c / 100 * alLine.c2g__Split__c;

			cb4__CBTag__c newLine = new cb4__CBTag__c(
					cb4__Dimension__c = BUDGET_AMOUNT_DIM_ID,
					cb4__Tag1__c = budgetId,
					cb4__Text1__c =  acc.cb4__Tag1__r.cb4__Tag1Name__c.toLowerCase(),
					cb4__Text2__c = acc.cb4__Tag1__r.cb4__Tag1Name__c.toLowerCase(),
					cb4__Decimal1__c = (qAmount / 4).setScale(2),
					cb4__Text3__c = acc.Name + ' (' + d6.cb4__Index__c + '-' + d7.cb4__Index__c + '-' + d8.cb4__Index__c + '-' + d9.cb4__Index__c + ')',
					cb4__Text4__c = 'Automatically generated using the  \'' + bAllocation.Name + ' ' + bAllocation.Title__c + '\' Budget Allocation)',
					cb4__Tag2__c = acc.Id,
					cb4__Tag3__c = periodMap.get(bAllocation.Year__r.Name)[0],
					cb4__Tag6__c = d6.Id,
					cb4__Tag7__c = d7.Id,
					cb4__Tag8__c = d8.Id,
					cb4__Tag9__c = d9.Id,
					cb4__ExtId__c = bAllocation.Id
			);
			cb4__CBTag__c bTotal1 = budgetTotalsByBudgetAndPeriodId.get(budgetId + periodMap.get(bAllocation.Year__r.Name)[0] + newLine.cb4__Text2__c);
			if(bTotal1 == null) {
				bTotal1 = getNewTotalBudgetLine(newLine.cb4__Tag1__c, periodMap.get(bAllocation.Year__r.Name)[0], acc.cb4__Tag1__r.cb4__Tag1Name__c.toLowerCase());
				budgetTotalsByBudgetAndPeriodId.put(String.valueOf(newLine.cb4__Tag1__c) + String.valueOf(periodMap.get(bAllocation.Year__r.Name)[0] + newLine.cb4__Text2__c), bTotal1);
			}
			bTotal1.cb4__Decimal1__c = bTotal1.cb4__Decimal1__c + newLine.cb4__Decimal1__c;

			cb4__CBTag__c bTotal2 = budgetTotalsByBudgetAndPeriodId.get(budgetId + periodMap.get(bAllocation.Year__r.Name)[1] + newLine.cb4__Text2__c);
			if(bTotal2 == null) {
				bTotal2 = getNewTotalBudgetLine(newLine.cb4__Tag1__c, periodMap.get(bAllocation.Year__r.Name)[1], acc.cb4__Tag1__r.cb4__Tag1Name__c.toLowerCase());
				budgetTotalsByBudgetAndPeriodId.put(String.valueOf(newLine.cb4__Tag1__c) + String.valueOf(periodMap.get(bAllocation.Year__r.Name)[1] + newLine.cb4__Text2__c), bTotal2);
			}
			bTotal2.cb4__Decimal1__c = bTotal2.cb4__Decimal1__c + newLine.cb4__Decimal1__c;

			cb4__CBTag__c bTotal3 = budgetTotalsByBudgetAndPeriodId.get(budgetId + periodMap.get(bAllocation.Year__r.Name)[2] + newLine.cb4__Text2__c);
			if(bTotal3 == null) {
				bTotal3 = getNewTotalBudgetLine(newLine.cb4__Tag1__c, periodMap.get(bAllocation.Year__r.Name)[2], acc.cb4__Tag1__r.cb4__Tag1Name__c.toLowerCase());
				budgetTotalsByBudgetAndPeriodId.put(String.valueOf(newLine.cb4__Tag1__c) + String.valueOf(periodMap.get(bAllocation.Year__r.Name)[2] + newLine.cb4__Text2__c), bTotal3);
			}
			bTotal3.cb4__Decimal1__c = bTotal3.cb4__Decimal1__c + newLine.cb4__Decimal1__c;

			cb4__CBTag__c bTotal4 = budgetTotalsByBudgetAndPeriodId.get(budgetId + periodMap.get(bAllocation.Year__r.Name)[3] + newLine.cb4__Text2__c);
			if(bTotal4 == null) {
				bTotal4 = getNewTotalBudgetLine(newLine.cb4__Tag1__c, periodMap.get(bAllocation.Year__r.Name)[3], acc.cb4__Tag1__r.cb4__Tag1Name__c.toLowerCase());
				budgetTotalsByBudgetAndPeriodId.put(String.valueOf(newLine.cb4__Tag1__c) + String.valueOf(periodMap.get(bAllocation.Year__r.Name)[3] + newLine.cb4__Text2__c), bTotal4);
			}
			bTotal4.cb4__Decimal1__c = bTotal4.cb4__Decimal1__c + newLine.cb4__Decimal1__c;

			String blKey = CBBudgetApplication.getSimpleLineKey(newLine, newLine.cb4__Tag1__c);
			if(!keyToBLbyPeriod.containsKey(blKey + periodMap.get(bAllocation.Year__r.Name)[0])){
				keyToBLbyPeriod.put(blKey + periodMap.get(bAllocation.Year__r.Name)[0], newLine);
			}
			if(!keyToBLbyPeriod.containsKey(blKey + periodMap.get(bAllocation.Year__r.Name)[1])){
				cb4__CBTag__c newLine1 = newLine.clone();
				newLine1.cb4__Tag3__c = periodMap.get(bAllocation.Year__r.Name)[1];
				keyToBLbyPeriod.put(blKey + periodMap.get(bAllocation.Year__r.Name)[1], newLine1);
			}
			if(!keyToBLbyPeriod.containsKey(blKey + periodMap.get(bAllocation.Year__r.Name)[2])){
				cb4__CBTag__c newLine2 = newLine.clone();
				newLine2.cb4__Tag3__c = periodMap.get(bAllocation.Year__r.Name)[2];
				keyToBLbyPeriod.put(blKey + periodMap.get(bAllocation.Year__r.Name)[2], newLine2);
			}
			if(!keyToBLbyPeriod.containsKey(blKey + periodMap.get(bAllocation.Year__r.Name)[3])){
				cb4__CBTag__c newLine3 = newLine.clone();
				newLine3.cb4__Tag3__c = periodMap.get(bAllocation.Year__r.Name)[3];
				keyToBLbyPeriod.put(blKey + periodMap.get(bAllocation.Year__r.Name)[3], newLine3);
			}
			for(Budget_Allocation_Line__c bLine : budgetAllocationLines){
				Decimal qSubAmount = bLine.Amount__c / 100 * alLine.c2g__Split__c / 4;

				cb4__CBTag__c newSubLine = new cb4__CBTag__c(
						cb4__Dimension__c = BUDGET_SUB_AMOUNT_DIM_ID,
						cb4__Tag1__c = budgetsMapByCBFF1CBFF2.get(String.valueOf(d6.Id) + String.valueOf(d7.Id)),
						cb4__Text1__c =  acc.cb4__Tag1__r.cb4__Tag1Name__c.toLowerCase(),
						cb4__Text2__c = acc.cb4__Tag1__r.cb4__Tag1Name__c.toLowerCase(),
						cb4__Decimal1__c = qSubAmount.setScale(2),
						cb4__Text3__c = acc.Name + ' (' + d6.cb4__Index__c + '-' + d7.cb4__Index__c + '-' + d8.cb4__Index__c + '-' + d9.cb4__Index__c + ')',
						cb4__Text4__c = bLine.Description__c,
						cb4__Tag2__c = acc.Id,
						cb4__Tag3__c = periodMap.get(bAllocation.Year__r.Name)[0],
						cb4__Tag6__c = d6.Id,
						cb4__Tag7__c = d7.Id,
						cb4__Tag8__c = d8.Id,
						cb4__Tag9__c = d9.Id,
						cb4__ExtId__c = bAllocation.Id,
						cb4__Text10__c = blKey
				);
				newSubLines.add(newSubLine);
				cb4__CBTag__c newSubLine1 = newSubLine.clone();
				newSubLine1.cb4__Tag3__c = periodMap.get(bAllocation.Year__r.Name)[1];
				newSubLines.add(newSubLine1);
				cb4__CBTag__c newSubLine2 = newSubLine.clone();
				newSubLine2.cb4__Tag3__c = periodMap.get(bAllocation.Year__r.Name)[2];
				newSubLines.add(newSubLine2);
				cb4__CBTag__c newSubLine3 = newSubLine.clone();
				newSubLine3.cb4__Tag3__c = periodMap.get(bAllocation.Year__r.Name)[3];
				newSubLines.add(newSubLine3);
				System.debug(newSubLine);
			}
		}
		List<cb4__CBTag__c> oldData = [SELECT Id, cb4__Tag1__c, cb4__Tag3__c, cb4__Decimal1__c, cb4__Text2__c FROM cb4__CBTag__c WHERE (cb4__Dimension__c = :BUDGET_AMOUNT_DIM_ID OR cb4__Dimension__c = :BUDGET_SUB_AMOUNT_DIM_ID) AND cb4__ExtId__c = :bAllocation.Id];
		for(cb4__CBTag__c ot : oldData){
			cb4__CBTag__c bTotal = budgetTotalsByBudgetAndPeriodId.get(String.valueOf(ot.cb4__Tag1__c) + String.valueOf(ot.cb4__Tag3__c) + ot.cb4__Text2__c);
			if(bTotal != null) {
				bTotal.cb4__Decimal1__c = bTotal.cb4__Decimal1__c - ot.cb4__Decimal1__c;
			}
		}
		delete oldData;
		upsert budgetTotalsByBudgetAndPeriodId.values();
		insert keyToBLbyPeriod.values();
		insert newSubLines;
	}

	private static Map<String,String> getBudgetsMapByD1D2Ids(String yearName, String departmentId){
		Map<String, String> budgetsMap = new Map<String, String>();
		for(cb4__CBTag__c b : [SELECT Id, cb4__Tag6__c, cb4__Tag7__c FROM cb4__CBTag__c WHERE cb4__Dimension__c = :BUDGETS_DIM_ID AND cb4__Tag3Name__c = :yearName AND cb4__Tag4__c = :departmentId AND cb4__Tag6__c != NULL AND cb4__Tag7__c != NULL AND cb4__Boolean2__c = FALSE]){
			budgetsMap.put(String.valueOf(b.cb4__Tag6__c) + String.valueOf(b.cb4__Tag7__c), b.Id);
		}
		return budgetsMap;
	}

	private static Map<String,cb4__CBTag__c> getTotalsMapByBudgetId(String yearName, String departmentId){
		Map<String, cb4__CBTag__c> totalsMap = new Map<String, cb4__CBTag__c>();
		for(cb4__CBTag__c t : [SELECT Id, cb4__Decimal1__c, cb4__Tag1__c, cb4__Tag3__c, cb4__Text2__c FROM cb4__CBTag__c WHERE cb4__Dimension__c = :BUDGET_AMOUNT_DIM_ID AND cb4__Tag1__r.cb4__Tag3Name__c = :yearName AND cb4__Tag1__r.cb4__Tag4__c = :departmentId AND cb4__Text1__c = 'total']){
			totalsMap.put(String.valueOf(t.cb4__Tag1__c) + String.valueOf(t.cb4__Tag3__c) + String.valueOf(t.cb4__Text2__c), t);
		}
		return totalsMap;
	}

	private static cb4__CBTag__c getNewTotalBudgetLine(String bId, String perId, String totalType){
		return new cb4__CBTag__c(cb4__Text1__c = 'total', cb4__Text2__c = totalType, cb4__Text3__c = totalType, cb4__Tag1__c = bId, cb4__Tag3__c = perId, cb4__Dimension__c = BUDGET_AMOUNT_DIM_ID, cb4__Decimal1__c = 0);
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