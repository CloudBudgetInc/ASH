@isTest(SeeAllData=true)
public with sharing class CustomTaskListControllerTest {
    
    @isTest(SeeAllData=true)
    public static void getRelatedEPTasksTest() {
        System.assert(CustomTaskListController.getRelatedEPTasks('a0k3u000017kMA9AAM').size() > 0);
        // System.assertEquals(0, CustomTaskListController.getRelatedEPTasks('a0k4C000001wzHwQAI').size());
    }
}