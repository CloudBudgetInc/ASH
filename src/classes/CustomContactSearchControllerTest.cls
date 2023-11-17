@isTest(SeeAllData=true)
public with sharing class CustomContactSearchControllerTest {
    @isTest(SeeAllData=true)
    public static void testCustomContactSearchControllerTest () {
        System.assert(CustomContactSearchController.searchContacts('a', false).size() > 0);
        System.assert(CustomContactSearchController.searchContacts('a', true).size() > 0);
    }
}