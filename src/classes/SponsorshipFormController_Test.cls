/**
* @author       mpaquin@fionta.com
* @date         11/20/17
*
* @description  Test class for the SponsorshipFormController class.
*               Retrieving the List of city is tested in the SponsorshipCityListController_Test file.
*/

@IsTest
private class SponsorshipFormController_Test {

    @TestSetup
    static void testSetup() {

    Account a = new Account();
    a.Name = 'Test Account';
    insert a;

    Product2 product = new Product2();
    product.Name = 'test Product';
    product.Family = 'HILITE';
    insert product;

    PricebookEntry standardPricebookEntry = new PricebookEntry();
    standardPricebookEntry.Product2Id = product.Id;
    standardPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
    standardPricebookEntry.UnitPrice = 1;
    standardPricebookEntry.IsActive = true;
    insert standardPricebookEntry;

    Pricebook2 customPricebook = new Pricebook2();
    customPricebook.IsActive = true;
    customPricebook.Name = 'Custom PriceBook';
    insert customPricebook;

    PricebookEntry customPricebookEntry = new PricebookEntry();
    customPricebookEntry.Product2Id = product.Id;
    customPricebookEntry.Pricebook2Id = customPricebook.Id;
    customPricebookEntry.UnitPrice = 1;
    customPricebookEntry.IsActive = true;
    insert customPricebookEntry;

    Campaign city1 = new Campaign();
    city1.Name ='Test Campaign 1';
    city1.City__c = 'Frederick';
    city1.State__c = 'MD';
    city1.Product__c = product.Id;
    insert city1;
    }

    @IsTest
    private static void createSponsorship() {
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        List<Campaign> campaigns = [SELECT Id, City_and_State__c, Name, Product__c FROM Campaign];
        Decimal amount = 10000 *campaigns.size();

        Test.startTest();
        String status = SponsorshipFormController.createSponsorShip(campaigns, amount, a.Id);
        Test.stopTest();

        List<Opportunity> sponsorships = [SELECT Id, CampaignId FROM Opportunity];
        List<OpportunityLineItem> olis = [SELECT Id FROM OpportunityLineItem];

        System.assertEquals(campaigns[0].Id, sponsorships[0].CampaignId);
        System.assert(olis.size()>0);
    }

    @IsTest
    private static void canCreateSponsorShip() {

        Boolean canCreateSponsorShip = SponsorshipFormController.canCreateSponsorShip();
        System.assertEquals(true, canCreateSponsorShip);
    }
    //todo create user that cannot create sponsorship to test error handling
    //todo test error handkling of createSponsorship
}