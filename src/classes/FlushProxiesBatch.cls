global class FlushProxiesBatch implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
       	List<Month_Close__c> params = Month_Close__c.getall().values();
		String companyKey = String.valueOf(params[0].Company__c);
	    String perPost = String.valueOf(params[0].PerPost__c);
        String type = 'Proxy';
		String query = 'SELECT Id ' + 
            'FROM c2g__ReportingBalance__c ' + 
            'WHERE PerPost__c = :perPost AND ' +            
        	'c2g__OwnerCompany__r.Key__c = :companyKey AND ' +
            'c2g__Type__c = :type';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c> scope) {  
        delete scope;
    }
    
    public void finish(Database.BatchableContext bc) {}
}