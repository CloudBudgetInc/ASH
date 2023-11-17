global class JournalPosterAshScheduled implements Schedulable, Database.Batchable<sObject> {
    
   global Database.QueryLocator start(Database.BatchableContext BC) { 

	    List<Month_Close__c> params = Month_Close__c.getall().values();
		String companyKey = 'ASH';
		FfaDataProvider provider = FfaDataProvider.getInstance();
		Id companyId = provider.getCompany(companyKey);
       	String perPost = String.valueOf(params[0].PerPost__c);
       	c2g__codaPeriod__c period = provider.getPeriod(companyKey, perPost);
       	Id periodId = period.Id;
       	String journalStatus = 'In Progress';
        String approvalStatus = 'Approved';

       	String query = 'SELECT Id ' + 
            'FROM c2g__codaJournal__c ' + 
            'WHERE c2g__OwnerCompany__c = :companyId AND ' + 
            'c2g__JournalStatus__c = :journalStatus AND ' + 
            'Approval_Status__c = :approvalStatus AND ' + 
            'Invalid_Lines__c = 0 AND ' + 
            'c2g__Period__c = :periodId';
		return Database.getQueryLocator(query);
    }
    
   	global void execute(Database.BatchableContext BC, List<c2g__codaJournal__c> someJournals) { 

        List<c2g__codaJournal__c> forUpdate = new List<c2g__codaJournal__c>();
        List<c2g.CODAAPICommon.Reference> refs = new List<c2g.CODAAPICommon.Reference>();        
        
		for( c2g__codaJournal__c someJournal : someJournals ) {
            someJournal.Flagged_for_Bulk_Post__c = true;
            forUpdate.add(someJournal);
            c2g.CODAAPICommon.Reference ref = c2g.CODAAPICommon.getRef(someJournal.Id, null);
            refs.add(ref);
       	}
        update forUpdate;
        c2g.CODAAPIJournal_12_0.BulkPostJournal(null, refs);
   }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new JournalPosterAshScheduled());
    }    
    
    global void finish(Database.BatchableContext bc) { }    
}