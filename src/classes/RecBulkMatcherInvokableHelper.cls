public class RecBulkMatcherInvokableHelper {

  @InvocableMethod(label='Bulk Match Personify' 
                   description='Bulk matches Personify transactions for the account in question.' 
                   category='Reconciliations')
    public static void invokeBulkMatching(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        // company, account, then bypassordermatching
    	Id batchJobId = Database.executeBatch(
            new ReconciliationBulkMatcherBatch(nestedParams.get(0), nestedParams.get(1), nestedParams.get(2)), 100);
    }
}