public class SummarizePeriodInvokable {

  	@InvocableMethod(label='Summarize period' 
                   description='Rolls all period activity to a journal for rollover purposes.' 
                   category='Year End') 
    public static void invokeSummarizePeriod(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        String company = nestedParams.get(0);
        String sourcePeriod = nestedParams.get(1);
        String targetPeriod = nestedParams.get(2);
        String type = nestedParams.get(3);
        Id batchJobId = Database.executeBatch(new SummarizePeriodBatch(company, sourcePeriod, targetPeriod, type));
    }
}