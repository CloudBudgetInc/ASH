trigger OpptyTrigger  on npsp__Allocation__c (after update) {
    OpportunityTriggerHandler.run();
}