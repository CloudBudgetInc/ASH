global class ConcurStageExpenseBatch implements Database.Batchable<sObject> {

    String batchId;
    public ConcurStageExpenseBatch(String batchId) {
        this.batchId = batchId;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //List<Concur_Batch__c> someBatches = [SELECT Id FROM Concur_Batch__c WHERE Processed__c = false 
        //    AND Type__c = 'Expense'];
		List<Concur_Batch__c> someBatches = [SELECT Id FROM Concur_Batch__c WHERE Id = :batchId];        
        Concur_Batch__c theBatch = someBatches.get(0);
        Id batchId = theBatch.Id;
    	List<ContentDocumentLink> someList = [SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :batchId]; // Concur batch Id here.
    	ContentDocumentLink cdl = someList.get(0);
    	Id contentDocumentId = cdl.ContentDocumentId;
        String query = 'SELECT FileExtension, Title, versiondata FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId and IsLatest=true';
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
                    shuttle.Type__c = 'Expense';
                    if(i==2)   { shuttle.Invoice_Number__c = more; }
                    if(i==4)   { shuttle.Vendor_ID__c = more; }
                    if(i==5)  { submitterLastName = more; }
                    if(i==6)  { submitterFirstName = more; }                    
                    if(i==10)  { 
                        if(more == 'ASH-RC') shuttle.Company_ID__c = 'ASHRC';
						else shuttle.Company_ID__c = more; 
                    }                    
                    if(i==17)  { shuttle.Transaction_Amount__c = more; }
                    if(i==18)  { shuttle.Concur_Id__c = more; }    
					if(i==19)  { shuttle.Concur_Key__c = more; }                    
                    if(i==24)  { shuttle.Apply_Date__c = more; }
                    if(i==26)  { shuttle.Description_1__c = more; }
                    if(i==70)  { shuttle.Description_1__c = more; }
                    if(i==162) { shuttle.Other_Payment_Type__c = more; }
                    if(i==164) { shuttle.Payment_Type__c = more; }
                    if(i==166) { shuttle.Account_Code__c = more; }
                    if(i==200) { 
                        if(more == 'ASH-RC') shuttle.Intercompany_ID__c = 'ASHRC';
                        else shuttle.Intercompany_ID__c = more;
                    }                    
                    if(i==201) { shuttle.Department__c = more; }
                    if(i==202) { shuttle.Program__c = more; }
                    if(i==203) { shuttle.Project__c = more; }
                    if(i==204) { shuttle.Other__c = more; }
                }
                i++;
            }
            shuttle.Submitter__c = submitterFirstName + ' ' + submitterLastName;
            shuttle.Concur_Batch__c = batchId;
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