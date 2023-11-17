public class OpportunityTriggerHandler {
    
    public static Boolean triggerDisabled = false;
    
    public static void run() {
        if (triggerDisabled) {
            return;
        }
        switch on Trigger.operationType {
            when AFTER_UPDATE {
                afterUpdate(Trigger.newMap);
            }
        }
    }
    
    public static void afterUpdate(Map<Id,sObject> newMap ){
        OpportunityTriggerHelper.createGAUProducts((Map<Id,npsp__Allocation__c>) newMap);
    }

}