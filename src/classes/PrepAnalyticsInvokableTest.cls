@isTest(SeeAllData = true)
public class PrepAnalyticsInvokableTest {

	/**
	 * This test is horrible, but I'm settling for a smoke test as I need to get this deployed 
	 * prior to impending sandbox refresh.
	 */    
    public static testMethod void testInvokable() {
        
        List<String> nestedParams = new List<String>();
        List<List<String>> params = new List<List<String>>();
        nestedParams.add('ASH');
        nestedParams.add('202212');
        nestedParams.add('false');
        params.add(nestedParams);
        PrepAnalyticsInvokable.prepAnalytics(params);
    }
}