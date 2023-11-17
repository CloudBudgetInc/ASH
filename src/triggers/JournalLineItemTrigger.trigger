trigger JournalLineItemTrigger on c2g__codaJournalLineItem__c (before insert, before update) {
    
    List<Journals__c> journalParams = Journals__c.getall().values();        
    String validate = String.valueOf(journalParams[0].Validate__c);
    Boolean validationActive = Boolean.valueOf(validate);
    
    if (Trigger.isBefore && !System.isBatch()) {
        if( trigger.isInsert || trigger.isUpdate ) {
            if(validationActive) {            
                ComboRuleProvider provider = ComboRuleProvider.getInstance();
                for( c2g__codaJournalLineItem__c someLine : Trigger.new ) {
                    
                    if(someLine.c2g__Journal__r.c2g__JournalDescription__c != 'ADP Payroll Integration') {
                        boolean valid = true;
                        if( someLine.c2g__LineType__c == 'Intercompany') {
                            valid = provider.validate(someLine.c2g__DestinationCompany__c,
                                someLine.c2g__GeneralLedgerAccount__c,
                                someLine.c2g__Dimension1__c, 
                                someLine.c2g__Dimension2__c,
                                someLine.c2g__Dimension3__c,
                                someLine.c2g__Dimension4__c);
                        } else {
                            valid = provider.validate(someLine.c2g__OwnerCompany__c, 
                                someLine.c2g__GeneralLedgerAccount__c,
                                someLine.c2g__Dimension1__c, 
                                someLine.c2g__Dimension2__c,
                                someLine.c2g__Dimension3__c, 
                                someLine.c2g__Dimension4__c);
                        }
                        if( valid == false ) {
                            someLine.Invalid__c = true; 
                            someLine.Validation_Timestamp__c = System.now();
                        } else {
                            someLine.Invalid__c = false;
                            someLine.Validation_Timestamp__c = System.now();
                        } 
                    }
                }
            }
        }
    }
}