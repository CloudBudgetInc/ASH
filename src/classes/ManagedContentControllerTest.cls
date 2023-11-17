@IsTest(SeeAllData=true)
public class ManagedContentControllerTest {
    @IsTest(SeeAllData=true)
    public static void testManagedContentController() {
        String contentType = 'compact';
        String managedContentIds_str = '';
        String topicNames_str = '';

        System.assert(ManagedContentController.getMContent(contentType, null, null, 'en_US').size() == 0);
    }
}