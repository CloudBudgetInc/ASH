trigger GAUAllocationTrigger on npsp__Allocation__c (after insert ) {
    GAUAllocationTriggerHandler.run();
}