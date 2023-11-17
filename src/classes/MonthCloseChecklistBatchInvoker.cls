public class MonthCloseChecklistBatchInvoker {

  @InvocableMethod(label='Generate Month Close Checklist' 
                   description='Generates template-managed checklist items to support the monthly close.' 
                   category='Month Close')
    public static void invokeMonthCloseChecklist(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        // company, then period
    	Id batchJobId = Database.executeBatch(
            new MonthlyCloseChecklistBatch(nestedParams.get(0), nestedParams.get(1)),1000);
    }
}