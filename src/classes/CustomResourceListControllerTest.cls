@IsTest(SeeAllData=true)
public with sharing class CustomResourceListControllerTest {
	@IsTest(SeeAllData=true)
	public static void testCustomResourceListController() {
		System.assert(CustomResourceListController.getContentVersions().size() > 0);
		System.assert(CustomResourceListController.getContentDistributionById('0682C000000gN5lQAW') == null);
		System.assert(CustomResourceListController.getContentDocumentsByLibrary('0682C000000gN5lQAW') == null);
	}
}