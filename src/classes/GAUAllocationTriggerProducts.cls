public class GAUAllocationTriggerProducts {
    
    public static void createGAUProducts( Map<Id,npsp__Allocation__c> newItems){
        
        List<Id> OpptyIdList = new List<Id>();
        Map<Id, List<Id>> gauOpptyMap = new Map<Id, List<Id>>();
          Map<Id, List<Id>> gauPaymentMap = new Map<Id, List<Id>>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        
        for(npsp__Allocation__c a : newItems.values()){
            if(gauOpptyMap.containsKey(a.npsp__General_Accounting_Unit__c)){
                gauOpptyMap.get(a.npsp__General_Accounting_Unit__c).add(a.npsp__Opportunity__c);
            } else {
                gauOpptyMap.put(a.npsp__General_Accounting_Unit__c, new List<Id>{a.npsp__Opportunity__c});
            }
        }
        
        List<DataMapping__c> dpc = [select Id,General_Accounting_Unit__c,Parent_Code__c,Parent_Product__c from DataMapping__c];
        for(DataMapping__c dm : dpc){
            
        }
        
        if(!gauOpptyMap.isEmpty()){
            for(Product2 p : [SELECT Id, General_Accounting_Unit__c FROM Product2 WHERE General_Accounting_Unit__c In :gauOpptyMap.keyset()]){
                for(Id opptyId : gauOpptyMap.get(p.General_Accounting_Unit__c)){
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.Product2Id = p.Id;
                    oli.OpportunityId = opptyId;
                    oliList.add(oli);
                }                    
        }
            
            if(!oliList.isEmpty()){
                insert oliList;
            }
        }
    }           
                
}