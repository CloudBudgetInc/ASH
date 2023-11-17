public class MonthCloseInvokableHelper {

  @InvocableMethod(label='Generate 2999s' 
                   description='Generates 2999 records for the balance sheet.' 
                   category='Month Close')
    public static void invokeMonthClose(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        // company, then period
    	Id batchJobId = Database.executeBatch(new MonthCloseBatch(nestedParams.get(0), nestedParams.get(1)),1000);
    }
}