global class AuditorGroupImportBatch implements Database.Batchable<sObject> {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Account__c, Subaccount__c, Description__c, Processed__c ' + 
		'FROM Auditor_Group_Import__c WHERE Processed__c = false';        
        //String query = 'SELECT Account__c, Subaccount__c, Label__c, Description__c, Processed__c ' + 
		//'FROM Auditor_Group_Import__c WHERE Processed__c = false';
		return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<Auditor_Group_Import__c> scope) {

		FfaDataProvider provider = FfaDataProvider.getInstance();
		List<Auditor_Group__c> forInsert = new List<Auditor_Group__c>();
		List<Auditor_Group_Import__c> forUpdate = new List<Auditor_Group_Import__c>();        
        
        for(Auditor_Group_Import__c someImport : scope) {
            if(someImport.Subaccount__c.length() < 11) {
                someImport.Reason__c = 'Bad subaccount.';
                forUpdate.add(someImport);
                continue;
            }

            Id gla = provider.getGlaCode(someImport.Account__c);
            Id dim1 = provider.getDimension1(someImport.Subaccount__c.substring(0,3));
            Id dim2 = provider.getDimension2(someImport.Subaccount__c.substring(3,6));
            Id dim3 = provider.getDimension3(someImport.Subaccount__c.substring(6,9));
            Id dim4 = provider.getDimension4(someImport.Subaccount__c.substring(9,11));

            if( gla == null || dim1 == null || dim2 == null || dim3 == null || dim4 == null) {
                someImport.Reason__c = 'GL or dimension was null.';
                forUpdate.add(someImport);
                continue;
            }

            Auditor_Group__c newAuditorGroup = new Auditor_Group__c();
            /**
            if(someImport.Label__c != null) { 
                newAuditorGroup.Label__c = someImport.Label__c;
            }*/
            if(someImport.Description__c != null) {
                newAuditorGroup.Description__c = someImport.Description__c;
            }
            newAuditorGroup.General_Ledger_Account__c = gla;
            newAuditorGroup.Dimension_1__c = dim1;
            newAuditorGroup.Dimension_2__c = dim2;
            newAuditorGroup.Dimension_3__c = dim3;
            newAuditorGroup.Dimension_4__c = dim4;
        
            someImport.Processed__c = true;
            forUpdate.add(someImport);
            forInsert.add(newAuditorGroup);
        }
        
        update forUpdate;
        insert forInsert;
    }

    public void finish(Database.BatchableContext bc) { }    
}