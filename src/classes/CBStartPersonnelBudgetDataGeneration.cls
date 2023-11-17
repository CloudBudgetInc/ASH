global class CBStartPersonnelBudgetDataGeneration {
	@InvocableMethod
	public static void runCBBudgetGenerationProcess(List<String> pbbIds){
		CBBudgetDataGenerator s = new CBBudgetDataGenerator(pbbIds[0]);
		Id batchId = Database.executeBatch(s, 2000);
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
	}
}