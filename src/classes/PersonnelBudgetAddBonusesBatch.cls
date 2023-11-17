global class PersonnelBudgetAddBonusesBatch implements Database.Batchable<sObject> {
    
    String batchId;
    
    public PersonnelBudgetAddBonusesBatch(String batchId) {
        this.batchId = batchId;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        
        String query = 'SELECT Id, Amount__c, Accounting_Company__c, ' + 
            'Program__r.c2g__ReportingCode__c ' + 
            'FROM Bonus_Template__c WHERE Active__c = true';
		return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Bonus_Template__c> bonusTemplates) {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();        
        
		Map<Integer, String> periodMappings = new Map<Integer, String>();
        periodMappings.put(1, '202401');
        periodMappings.put(2, '202402');        
        periodMappings.put(3, '202403');
        periodMappings.put(4, '202404');
        periodMappings.put(5, '202405');
        periodMappings.put(6, '202406');
        periodMappings.put(7, '202407');
        periodMappings.put(8, '202408');
        periodMappings.put(9, '202409');
        periodMappings.put(10, '202410');
        periodMappings.put(11, '202411');
        periodMappings.put(12, '202412');

        List<Personnel_Budget_Stager__c> forInsert = new List<Personnel_Budget_Stager__c>();
        for( Bonus_Template__c bonusTemplate : bonusTemplates ) {        
            String accountSubaccount = '9045-302-' + bonusTemplate.Program__r.c2g__ReportingCode__c + '-000-00';
            String account = '9045';
            String subaccount = '302' + bonusTemplate.Program__r.c2g__ReportingCode__c + '00000';
            
            for (Integer count = 1; count < 13; count++) {
            Personnel_Budget_Stager__c stager = new Personnel_Budget_Stager__c();
                stager.Period__c = periodMappings.get(count);
                stager.Accounting_Company__c = bonusTemplate.Accounting_Company__c;
                stager.Program__c = bonusTemplate.Program__r.c2g__ReportingCode__c;
                stager.Amount__c = bonusTemplate.Amount__c/12;
                stager.Type__c = 'Bonus Pool';
                stager.Personnel_Budget_Batch__c = batchId; 
                stager.General_Ledger_Account__c = provider.getGlaCode('9045');
                stager.Dimension_1__c = provider.getDimension1('302');
                stager.Dimension_2__c = provider.getDimension2(bonusTemplate.Program__r.c2g__ReportingCode__c);
                stager.Dimension_3__c = provider.getDimension3('000');
                stager.Dimension_4__c = provider.getDimension4('00');                 
                forInsert.add(stager);
            }
        }
        insert forInsert;
    }

    global void finish(Database.BatchableContext bc) { }    
}