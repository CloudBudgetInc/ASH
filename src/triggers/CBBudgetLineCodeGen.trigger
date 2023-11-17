trigger CBBudgetLineCodeGen on cb4__CBTag__c (before insert, before update) {
	Id codeDimId = [SELECT Id FROM cb4__CBDimension__c WHERE Name = 'Subaccount Code'].Id;
	Map<String, Id> codeToTagMap = new Map<String, Id>();
	for(cb4__CBTag__c code: [SELECT Id, Name FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Subaccount Code']){
		codeToTagMap.put(code.Name, code.Id);
	}

	Map<Id, cb4__CBTag__c> dimMap = new Map<Id, cb4__CBTag__c>([SELECT Id, cb4__Index__c FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'CB_FF1' OR cb4__DimensionName__c = 'CB_FF2' OR cb4__DimensionName__c = 'CB_FF3' OR cb4__DimensionName__c = 'CB_FF4']);
	List<cb4__CBTag__c> blWithoutCode = new List<cb4__CBTag__c>();
	Map<String, cb4__CBTag__c> newCodesMap = new Map<String, cb4__CBTag__c>();
	for(cb4__CBTag__c bl : Trigger.new){
		if(bl.cb4__DimensionName__c == 'Budget App SubAmount' || bl.cb4__DimensionName__c == 'Budget App Amount' || bl.cb4__DimensionName__c == 'CB Reporting Balance'){
			String codeName = getCode(bl);
			Id codeId = codeToTagMap.get(codeName);
			if(bl.cb4__DimensionName__c == 'Budget App SubAmount' || bl.cb4__DimensionName__c == 'Budget App Amount') {
				if(codeId != null){
					bl.cb4__Tag5__c = codeId;
				}else{
					blWithoutCode.add(bl);
					newCodesMap.put(codeName , new cb4__CBTag__c(Name = codeName, cb4__Dimension__c = codeDimId));
				}
			}else{
				if(codeId != null){
					bl.cb4__Text7__c = codeId;
					bl.cb4__Text6__c = codeName;
				}else{
					blWithoutCode.add(bl);
					newCodesMap.put(codeName, new cb4__CBTag__c(Name = codeName, cb4__Dimension__c = codeDimId));
				}
			}
		}
	}
	if(newCodesMap.size() > 0){
		insert newCodesMap.values();
		for(cb4__CBTag__c bll : blWithoutCode){
			String cName = getCode(bll);
			Id codeIdd = newCodesMap.get(cName).Id;
			codeToTagMap.put(cName, codeIdd);
			if(bll.cb4__DimensionName__c == 'Budget App SubAmount' || bll.cb4__DimensionName__c == 'Budget App Amount') {
				bll.cb4__Tag5__c = codeIdd;
			}else{
				bll.cb4__Text6__c = cName;
				bll.cb4__Text7__c = codeIdd;
			}
		}
	}

	public String getCode(cb4__CBTag__c t){
		String code1 = dimMap.get(t.cb4__Tag6__c) != null ? dimMap.get(t.cb4__Tag6__c).cb4__Index__c : '';
		String code2 = dimMap.get(t.cb4__Tag7__c) != null ? dimMap.get(t.cb4__Tag7__c).cb4__Index__c : '';
		String code3 = dimMap.get(t.cb4__Tag8__c) != null ? dimMap.get(t.cb4__Tag8__c).cb4__Index__c : '';
		String code4 = dimMap.get(t.cb4__Tag9__c) != null ? dimMap.get(t.cb4__Tag9__c).cb4__Index__c : '';
		String codeName = code1 + (code2 != '' ? '-' + code2 : code2) + (code3 != '' ? '-' + code3 : code3) + (code4 != '' ? '-' + code4 : code4);
		codeName = codeName != '' ? codeName : '-';
		return codeName;
	}
}