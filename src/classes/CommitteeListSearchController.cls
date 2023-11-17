public with sharing class CommitteeListSearchController {
  

    @AuraEnabled(cacheable=true)
    public static List<Account> getCommittees(string searchText, string customerClass, boolean showOnlyActive) {
        List<Account> committees;
        List<RecordType> recordTypes = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Account' AND DeveloperName = 'Committee' 
            LIMIT 1
        ];
        string searchTextWildCard = '%' + searchText + '%';

        string active = 'Active';
        string inactive = showOnlyActive ? '' : 'Inactive';

        if(recordTypes.size() == 1){
            if (searchText.length() > 0 && customerClass.length() > 0) {
                committees = [
                    SELECT id, Name, Class__c, Personify_ID__c, Status__c 
                    FROM Account 
                    WHERE RecordTypeId = :recordTypes[0].Id 
                    AND Class__c = :customerClass 
                    AND Status__c IN (:active, :inactive) 
                    AND Name LIKE :searchTextWildCard
                    Order by Name, Class__c
                ];
            }
            else if (searchText.length() > 0) {
                committees = [
                    SELECT id, Name, Class__c, Personify_ID__c, Status__c 
                    FROM Account 
                    WHERE RecordTypeId = :recordTypes[0].Id 
                    AND Status__c IN (:active, :inactive) 
                    AND Name like :searchTextWildCard
                    Order by Name, Class__c
                ];
            }
            else if (customerClass.length() > 0){
                committees = [
                    SELECT id, Name, Class__c, Personify_ID__c, Status__c 
                    FROM Account 
                    Where RecordTypeId = :recordTypes[0].Id 
                    AND Status__c IN (:active, :inactive) 
                    AND Class__c = :customerClass
                    Order by Name, Class__c
                ];
            }
            else {
                committees = [
                    SELECT id, Name, Class__c, Personify_ID__c, Status__c 
                    FROM Account 
                    WHERE RecordTypeId = :recordTypes[0].Id
                    AND Status__c IN (:active, :inactive) 
                    Order by Name, Class__c
                ];
            }
        }     
        

        return committees;
    }

    @AuraEnabled (cacheable=true)
    public static List<Committee_Customer_Class__mdt> getCustomerClasses(){
        List<Committee_Customer_Class__mdt> classes = [Select MasterLabel from Committee_Customer_Class__mdt Order by MasterLabel];
        return classes;
    }
}