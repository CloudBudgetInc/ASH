global class ConcurStageInvoiceBatch implements Database.Batchable<sObject> {

    String batchId;
    
    public ConcurStageInvoiceBatch(String batchId) {
        this.batchId = batchId;
    }         
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
		// Go grab the file attachment linked to the originating batch.
		List<ContentDocumentLink> someList = [SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :batchId]; // Concur batch Id here.
		ContentDocumentLink cdl = someList.get(0);
		Id contentDocumentId = cdl.ContentDocumentId;
        String query = 'SELECT FileExtension, Title, versiondata FROM ContentVersion ' + 
            'WHERE ContentDocumentId = :contentDocumentId and IsLatest=true';
		return Database.getQueryLocator(query);
	}
		    
    global void execute(Database.BatchableContext BC, List<ContentVersion> scope) {

		ContentVersion someCv = scope.get(0);
		Blob csvFileBody = someCv.VersionData;
		String csvAsString = csvFileBody.toString();
		List<String> csvFileLines = csvAsString.split('\n');

		List<Payment_Shuttle__c> somePayments = new List<Payment_Shuttle__c>();
        
        csvFileLines.remove(0); // first line is essentially header detail which can be omitted.
        for( String line : csvFileLines)
        {
            Payment_Shuttle__c shuttle = new Payment_Shuttle__c();
            Integer i = 0;
            String submitterFirstName;
            String submitterLastName;
            List<String> moreSplits = line.split('\\|');
            for( String more : moreSplits) {
                if(more <> '') {
                    //System.debug(i + ' ' + more);
					if(i==1)   { shuttle.Concur_Key__c = more; }
					if(i==3)   { shuttle.Invoice_Name__c = more; }
					if(i==5)   { shuttle.Invoice_Number__c = more; }
					if(i==6)   { shuttle.Invoice_Date__c = more; }
                    if(i==26)  { shuttle.Type__c = more; }
                    if(i==50)  { shuttle.Concur_Id__c = more; }
                    if(i==62)  { shuttle.Transaction_Amount__c = more; }
                    if(i==28)  { 
                        if(more == 'ASH-RC') shuttle.Company_ID__c = 'ASHRC';
						else shuttle.Company_ID__c = more; 
                    } 
                    if(i==67)  { shuttle.Account_Code__c = more; }
                    if(i==73)  { shuttle.Reimbursement__c = more; }
                    if(i==74)  { shuttle.Charitable_Program__c = more; }
                    if(i==78)  { shuttle.Officer__c = more; }
                    if(i==79)  { shuttle.Expense_Year__c = more; }
                    if(i==80)  { shuttle.Prepaid_Start_Date__c = more; }
                    if(i==81)  { shuttle.Prepaid_End_Date__c = more; }
                    if(i==82)  { shuttle.X1099_Number__c = more; }
                    if(i==83)  { 
                        if(more == 'ASH-RC') shuttle.Intercompany_ID__c = 'ASHRC'; 
                        else shuttle.Intercompany_ID__c = more;
                    }                    
                    if(i==84)  { shuttle.Department__c = more; }
                    if(i==85)  { shuttle.Program__c = more; }
                    if(i==86)  { shuttle.Project__c = more; }
                    if(i==87)  { shuttle.Other__c = more; }
                    if(i==63)  { shuttle.Sign__c = more; }
                    if(i==95)  { submitterFirstName = more; }
                    if(i==97)  { submitterLastName = more; }
                    if(i==132) { shuttle.Description_1__c = more; }
                    if(i==164) { shuttle.Vendor_ID__c = more; }
                }
                i++;
            }
            shuttle.Submitter__c = submitterFirstName + ' ' + submitterLastName;
            shuttle.Concur_Batch__c = batchId;
            shuttle.Source__c = 'Invoice';
            somePayments.add(shuttle);
        }
        
        insert somePayments;
    }
    
    global void finish(Database.BatchableContext bc) { 
    	Concur_Batch__c newBatch = [SELECT Id FROM Concur_Batch__c WHERE Id = :batchId];
        newBatch.Staged__c = true;
        update newBatch;
    }
}