public class ConcurInvoiceInvokableHelper {

  	@InvocableMethod(label='Invoke Concur Invoice' 
                   description='Initiates the staging or processing of a Concur Invoice Extract.' 
                   category='Concur') 
    public static void invokeConcurInvoice(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        String type = nestedParams.get(0);
        if(type == 'Stage') { 
            // Batch Id.
	        Id batchJobId = Database.executeBatch(new ConcurStageInvoiceBatch(nestedParams.get(2)));
        }
        else { // 'Process'
            // Company, Batch Id.
            Id batchJobId = Database.executeBatch(
                new ConcurProcessInvoiceBatch(nestedParams.get(1), nestedParams.get(2)), 1000);
        }
    }
}