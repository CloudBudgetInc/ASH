public class GAUAllocationTriggerHandler {
    
    public static Boolean triggerDisabled = false;
    
    public static void run() {
        if (triggerDisabled) {
            return;
        }
        switch on Trigger.operationType {
            when AFTER_INSERT {
                afterInsert(Trigger.newMap);
            }
        }
    }
    
    public static void afterInsert(Map<Id,sObject> newMap){
        GAUAllocationTriggerHelper.createGAUProducts((Map<Id,npsp__Allocation__c>) newMap);
    }

}