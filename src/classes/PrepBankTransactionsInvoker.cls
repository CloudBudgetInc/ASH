public class PrepBankTransactionsInvoker {
	@InvocableMethod(label='Invoke Prep Bank Transactions' 
                   description='Sets up various transactions related to bank matching.' 
                   category='Accounting')
    public static void invokePrepBankTransactions(List<List<String>> params) {
        List<String> nestedParams = params.get(0);
        String period = nestedParams.get(0);
        String generalLedgerAccount = nestedParams.get(1);
        String batchSize = nestedParams.get(2);
		Id batchJobId = Database.executeBatch(new PrepBankTransactionsBatch(period, generalLedgerAccount), Integer.valueOf(batchSize));
  	}
}