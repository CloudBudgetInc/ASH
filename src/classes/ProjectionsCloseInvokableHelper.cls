public class ProjectionsCloseInvokableHelper {
    
  @InvocableMethod(label='Close Projections' 
                   description='Closes out projections by permanently storing revisions.'
                   category='Projections')
    public static void invokeProjectionsClose(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        // company, year, period
    	Id batchJobId = Database.executeBatch(
            new ProjectionsCloseBatch(nestedParams.get(0), nestedParams.get(1), nestedParams.get(2)),1000);
    }
}