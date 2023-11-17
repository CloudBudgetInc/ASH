public class JournalizePrepaidReclassInvoker {
	@InvocableMethod(label='Invoke Prepaid Reclass Journalization' 
                   description='Converts a prepaid reclass to a series of prepaid journals.' 
                   category='Accounting')
    public static void invokePrepaidReclassJournalization(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        String reclass = nestedParams.get(0);
        String period = nestedParams.get(1);
		Id batchJobId = Database.executeBatch(new JournalizePrepaidReclass(reclass, period));
  	}
}