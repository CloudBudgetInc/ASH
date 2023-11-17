public class ProjectionsPrepInvokableHelper {
    
  @InvocableMethod(label='Prep Projections' 
                   description='Opens the projections process by prepping Projections records with Actuals and Budget data.'
                   category='Projections')
    public static void invokeProjectionsPrep(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        // company, year, period
    	Id batchJobId = Database.executeBatch(
            new ProjectionsPrepBatch(nestedParams.get(0), nestedParams.get(1), nestedParams.get(2)),100);
    }
}