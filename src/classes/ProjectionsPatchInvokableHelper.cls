public class ProjectionsPatchInvokableHelper {
    
  @InvocableMethod(label='Patch Projections' 
                   description='Patches the projections by inserting projections where no budget/projections existed.'
                   category='Projections')
    public static void invokeProjectionsPatch(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        // company, year, period
    	Id batchJobId = Database.executeBatch(
            new ProjectionsPatchBatch(nestedParams.get(0), nestedParams.get(1), nestedParams.get(2)),1000);
    }
}