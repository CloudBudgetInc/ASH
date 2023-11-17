public class RecMatcherInvokableHelper {
  @InvocableMethod(label='2-Way Match Personify' 
                   description='2-way matches Personify transactions for the account in question.' 
                   category='Reconciliations')
    public static void invokeMatching(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        String account = nestedParams.get(0);
        String dateMatchingActive = nestedParams.get(1);
    	Id batchJobId = Database.executeBatch(
            new ReconciliationMatcherBatch(account, dateMatchingActive), 1000);
    }
}