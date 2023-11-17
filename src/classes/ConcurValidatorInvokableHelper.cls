public class ConcurValidatorInvokableHelper {
  	@InvocableMethod(label='Validate Concur Batch' 
                   description='Initiates the validation of a Concur Batch.' 
                   category='Concur') 
    public static void validateConcurBatch(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
    	Id batchJobId = Database.executeBatch(new ConcurValidateBatch(nestedParams.get(0)), 500);
    }
}