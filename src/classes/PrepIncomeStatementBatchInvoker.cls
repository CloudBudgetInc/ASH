public class PrepIncomeStatementBatchInvoker {
    
  @InvocableMethod(label='Preps the self-service income statement.' 
                   description='Preps the self-service income statement.' 
                   category='Reporting')
    public static void invokeIncomeStatementPrep(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
		// Company, Period.
		String company = nestedParams.get(0);
        String period = nestedParams.get(1);
        Id batchJobId = Database.executeBatch(new PrepIncomeStatementBatch(nestedParams.get(0), nestedParams.get(1)), 1000);
    }
}