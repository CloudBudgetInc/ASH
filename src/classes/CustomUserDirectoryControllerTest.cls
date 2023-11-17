@IsTest(SeeAllData=true)
public with sharing class CustomUserDirectoryControllerTest {
    @IsTest(SeeAllData=true)
    public static void testCustomUserDirectoryController() {
        System.assert(CustomUserDirectoryController.getContactJunction().size() > 0);
    }
}