public class ConcurExpenseInvokableHelper {

  	@InvocableMethod(label='Invoke Concur Expense' 
                   description='Initiates the staging or processing of a Concur Expense Extract.' 
                   category='Concur') 
    public static void invokeConcurExpense(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        String type = nestedParams.get(0);
        if(type == 'Stage') { 
	        Id batchJobId = Database.executeBatch(new ConcurStageExpenseBatch(nestedParams.get(2)));
        }
        else { // 'Process'
            // Company, Batch ID.
            Id batchJobId = Database.executeBatch(
                new ConcurProcessExpenseBatch(nestedParams.get(1), nestedParams.get(2)), 500);
        }
    }
}