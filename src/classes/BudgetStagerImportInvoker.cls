public class BudgetStagerImportInvoker {

  @InvocableMethod(label='Invokes an import from budget stagers' 
                   description='Invokes an import from budget stagers.' 
                   category='Budgeting')
    public static void invokeBudgetImport(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        // Personnel Budget Batch Id
      	Id batchJobId = Database.executeBatch(new BudgetStagerImportBatch(nestedParams.get(0)),1000);
    }
}