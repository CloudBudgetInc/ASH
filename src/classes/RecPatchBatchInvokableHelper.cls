public class RecPatchBatchInvokableHelper {

  @InvocableMethod(label='Patch Personify' 
                   description='Patches Personify transactions with transaction originating from FF.' 
                   category='Reconciliations')
    public static void invokeRecPatching(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        // company, period, account
    	Id batchJobId = Database.executeBatch(
            new ReconciliationsPatchBatch(nestedParams.get(0), nestedParams.get(1), nestedParams.get(2)), 1000);
    }
}