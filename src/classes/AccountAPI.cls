@RestResource(urlMapping='/AccountGAL/*')
global with sharing class AccountAPI {
 
   @HttpDelete
    global static void doDelete() {
        System.debug('Method@4');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        npsp__General_Accounting_Unit__c account = [SELECT Id FROM npsp__General_Accounting_Unit__c WHERE Id = :accountId];
        delete account;
    }
 
    @HttpGet
    global static npsp__General_Accounting_Unit__c doGet() {
        System.debug('I am in get method@5');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        npsp__General_Accounting_Unit__c result = [SELECT Id FROM npsp__General_Accounting_Unit__c WHERE Id = :accountId];
        return result;
    }
 
    @HttpPost
    global static String doPost(Id IdVal) {
        System.debug('I am in post method@6');
        npsp__General_Accounting_Unit__c account = new npsp__General_Accounting_Unit__c();
        account.Id = IdVal;
         insert account;
        return account.Id;        
       
    }
 
}