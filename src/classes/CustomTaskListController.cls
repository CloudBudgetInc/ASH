public with sharing class CustomTaskListController {

    @AuraEnabled(cacheable = true)
    public static List<Task> getRelatedEPTasks(Id id) {
        List<Task> taskList = [
            SELECT Id, Subject, Completed_Date__c, ActivityDate, Owner.Name, Status, Priority, LastModifiedDate, npsp__Engagement_Plan__c, isDeleted 
            FROM Task
            WHERE npsp__Engagement_Plan__c = :id AND isDeleted = false
            ORDER BY Subject
            ALL ROWS
        ];

        if (taskList.isEmpty()) {
            return null;
        }

        return taskList;
    }
}