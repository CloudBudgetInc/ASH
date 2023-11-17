/**
*————————————————————————————————————————————————————----------------------------------------------
* @Name             SponsorshipFormController
* @Author           Max Paquin mpaquin@fionta.com
* @Created Date     11/20/17
* @Used By          SponsorshipCityForm Lightning Component
*————————————————————————————————————————————————————----------------------------------------------
* @Description
*                   Used to verify the user can create Opportunity records
*                   AND
*                   to create Opportunity and OpportunityLineItem records.
*————————————————————————————————————————————————————----------------------------------------------
**/

public with sharing class SponsorshipFormController {

    @AuraEnabled
    public static Boolean canCreateSponsorShip(){

        if(userCanCreateOpps() && confirmFieldAccess()){
         return true;
        } else{
            AuraHandledException e = new AuraHandledException('Insufficient right to create record or field access');
            e.setMessage('Insufficient right to create record or field access');
            throw e;
        }
    }

    @AuraEnabled
    public Static String createSponsorship(List<Campaign> campaigns,  Decimal amount , Id accountId){

        String dmlMessage;
        List<Opportunity> opps = new List<Opportunity>();
        try{
            opps = createOpportunities(campaigns, amount, accountId);
        }catch (Exception oppException){
            System.debug(oppException);
            System.debug(oppException.getLineNumber());
            AuraHandledException auraException = new AuraHandledException(oppException.getMessage());
            auraException.setMessage(oppException.getMessage());
            throw auraException;
        }

        try{
            createOpportunityLineItems(opps, campaigns);
        }catch (Exception oliException){
            System.debug(oliException);
            System.debug(oliException.getLineNumber());
            AuraHandledException auraException = new AuraHandledException(oliException.getMessage());
            auraException.setMessage(oliException.getMessage());
            throw auraException;
        }

        return dmlMessage;
    }

    private static List<Opportunity> createOpportunities(List<Campaign> campaigns,  Decimal amount , Id accountId){

        Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId];

        List<Opportunity> opps = new List<Opportunity>();
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Exhibit').getRecordTypeId();
        Pricebook2 priceBook = [SELECT Id FROM Pricebook2 WHERE IsActive = true];

        for(Campaign camp :campaigns){
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Amount = amount/campaigns.size();
            opp.CloseDate = Date.today();
            String sponsorshipDate = opp.CloseDate.month()+'/'+opp.CloseDate.day()+'/'+opp.CloseDate.year();
            opp.Name = acc.Name + ' ' +camp.Name +' ' +sponsorshipDate;
            opp.StageName = 'Closed Won';
            opp.CampaignId = camp.Id;
            opp.RecordTypeId =recordTypeId;
            opp.Pricebook2Id = priceBook.Id;
            opps.add(opp);
        }

        insert opps;
        return opps;
    }

    private static void createOpportunityLineItems(List<Opportunity> opps, List<Campaign> campaigns){

        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        Map<Id,Campaign> campaignsByIds = new Map<Id, Campaign>(campaigns);
        Map<String, PricebookEntry> pbeByProductId = getPricebookEntries(campaigns);

        for(Opportunity opp :opps){
            Campaign camp = campaignsByIds.get(opp.CampaignId);
            PricebookEntry PBE = pbeByProductId.get(camp.Product__c);
            if(PBE != null) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opp.Id;
                oli.Product2Id = camp.Product__c;
                oli.Quantity = 1;
                oli.UnitPrice = opp.Amount;
                oli.PricebookEntryId = PBE.Id;
                olis.add(oli);
            }
        }
        insert olis;
    }

    private static Map<String, PricebookEntry> getPricebookEntries(List<Campaign> campaigns){

        Set<Id> productIds = getProductIdsFromCampaigns(campaigns);
        Map<String, PricebookEntry> pbeByProductId = new Map<String, PricebookEntry>();

        List<PricebookEntry> PBEs = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds AND IsActive = true];

        for(PricebookEntry PBE :PBEs){
            pbeByProductId.put(pbe.Product2Id, PBE);
        }
        return pbeByProductId;
    }

    private static Set<Id> getProductIdsFromCampaigns(List<Campaign> campaigns){

        Set<Id> productIds = new Set<Id>();
        for(Campaign camp : campaigns){
            productIds.add(camp.Product__c);
        }

        return productIds;
    }

    private static Boolean userCanCreateOpps(){

        Boolean isCreatable = Schema.SObjectType.Opportunity.isCreateable();

        return isCreatable;
    }

    private static Boolean confirmFieldAccess(){

        Boolean fieldsAreUpdateable = false;
        Boolean amountAccess = Schema.SObjectType.Opportunity.fields.Amount.isUpdateable();
        Boolean campaignAccess = Schema.SObjectType.Opportunity.fields.CampaignId.isUpdateable();

        if(amountAccess && campaignAccess){
            fieldsAreUpdateable = true;
        }

        return fieldsAreUpdateable;
    }

}