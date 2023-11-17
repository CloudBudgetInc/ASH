public class OpportunityTriggerHelper {
    
    public static void createGAUProducts( Map<Id,npsp__Allocation__c> newItems){
        
        List<Id> OpptyIdList = new List<Id>();
        Map<Id, List<Id>> gauOpptyMap = new Map<Id, List<Id>>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        
        for(npsp__Allocation__c a :  newItems.values()){
            if(gauOpptyMap.containsKey(a.npsp__General_Accounting_Unit__c)){
                gauOpptyMap.get(a.npsp__General_Accounting_Unit__c).add(a.npsp__Opportunity__c);
            } else {
                gauOpptyMap.put(a.npsp__General_Accounting_Unit__c, new List<Id>{a.npsp__Opportunity__c});
            }
        }
        
        String nub ;
        String dmcd ;
        String ded;
        if(!gauOpptyMap.isEmpty()){
            System.debug('KeySet values'+gauOpptyMap.keyset());
            for(npsp__General_Accounting_Unit__c ngau : [SELECT Name FROM npsp__General_Accounting_Unit__c WHERE Id  =: gauOpptyMap.keyset()]){
                String nps = [SELECT Name FROM npsp__General_Accounting_Unit__c WHERE Id  IN : gauOpptyMap.keyset() limit 1].Name;
                for(npe01__OppPayment__c nppm : [select Id,npe01__Opportunity__c, npe01__OppPayment__c.npe01__Payment_Method__c from npe01__OppPayment__c where npe01__Opportunity__c =:  ApexPages.currentPage().getParameters().get('Id')]){
                    Opportunity recordTypePerson = [select RecordTypeId from Opportunity where Id=:nppm.npe01__Opportunity__c];
                    //Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(nppm.npe01__Opportunity__c).getRecordTypeId();
                    Opportunity AccId = [Select AccountId from Opportunity  where Id =: nppm.npe01__Opportunity__c];
                    for(DataMapping__c dmc :  [select Id,Parent_Code__c,General_Accounting_Unit__c,Payment_Method__c,Account_Record_Type__c,Account_Type__c from DataMapping__c where General_Accounting_Unit__c =: ngau.Name]){
                        System.debug('KeySet@4'+ nppm.npe01__Payment_Method__c);
                        System.debug('KeySet@5'+  dmc.Payment_Method__c);
                        if(nppm.npe01__Payment_Method__c == dmc.Payment_Method__c ){
                            String prdId = [SELECT Id FROM product2 WHERE ProductCode =: dmc.Parent_Code__c limit 1].Id;
                            system.debug('product val'+prdId);
                            OpportunityLineItem oli = new OpportunityLineItem();
                            oli.Product2Id = prdId;
                            String PriceEntryId = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prdId limit 1].Id;
                            system.debug('PriceId'+ PriceEntryId);
                            oli.PricebookEntryId  = PriceEntryId;//PriceEntryId;
                            oli.OpportunityId = ApexPages.currentPage().getParameters().get('Id');
                            oliList.add(oli);
                        }
                    } 
                    if(!oliList.isEmpty()){
                        insert oliList;
                    }
                }
            } 
        }
    }
}