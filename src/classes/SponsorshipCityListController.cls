/**
*————————————————————————————————————————————————————----------------------------------------------
* @Name             SponsorshipCityListController
* @Author           Max Paquin mpaquin@fionta.com
* @Created Date
* @Used By          SponsorshipCityList Lightning Component
*————————————————————————————————————————————————————----------------------------------------------
* @Description
*                   Provides a list of Campaign records
*                   that will be used as "Cities"
*————————————————————————————————————————————————————----------------------------------------------
**/

public with sharing class SponsorshipCityListController {

    @AuraEnabled
    public static List<Campaign> getCities(){
            List<Campaign> cities = [SELECT Id, Name, Campaign_Year__c, Product__c,City_State_and_Continent__c
                                    FROM Campaign
                                    WHERE IsActive = true AND Type = 'Conference' AND
                                    Status IN ('Planned','In-Progress') AND
                                    City__c != null AND (State__c != null OR Continent__c != null) AND
                                    StartDate != null AND EndDate != null ORDER BY City_State_and_Continent__c];
            return cities;
    }
}