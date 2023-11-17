public class PayableImageFixerInvokableHelper {
  	@InvocableMethod(label='Fetch Invoice Backup from Concur' 
                   description='Fetch Invoice File Support from Concur' 
                   category='Concur') 
    public static void fetchPayableInvoiceImages(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        String batchSize = nestedParams.get(0);
    	Id batchJobId = Database.executeBatch(new PayableImageFixerBatch(),Integer.valueOf(batchSize));
    }
}