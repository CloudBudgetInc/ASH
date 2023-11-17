/**
*————————————————————————————————————————————————————----------------------------------------------
* @Name             SponsorshipCityListController_Test
* @Author           Max Paquin mpaquin@fionta.com
* @Created Date     11/20/17
* @Used By          SponsorshipCityList Apex Class
*————————————————————————————————————————————————————----------------------------------------------
* @Description
*                   To test the SponsorshipCityList Apex Class.
*————————————————————————————————————————————————————----------------------------------------------
**/
@IsTest
public with sharing class SponsorshipCityListController_Test {

    @TestSetup
    static void testSetup(){

        Campaign camp1 = new Campaign();
        camp1.Name = 'Test 1';
        camp1.State__c = 'MD';
        camp1.City__c = 'Frederick';
        camp1.Continent__c = 'North America';
        camp1.IsActive = true;
        camp1.Status = 'Planned';
        camp1.StartDate  = Date.today();
        camp1.EndDate = Date.today();
        camp1.Type = 'Conference';
        insert camp1;

    }

    @IsTest
    private static void getCities(){

        List<campaign> campaigns = new List<Campaign>();

        Test.startTest();
        campaigns = SponsorshipCityListController.getCities();
        Test.stopTest();

        System.assertNotEquals(null, campaigns);
        System.assertEquals('Frederick, MD, North America', campaigns[0].City_State_and_Continent__c);
    }
}