@IsTest(SeeAllData=true)
public with sharing class CustomLibraryPickListTest {
	@IsTest(SeeAllData=true)
	public static void testCustomLibraryPickList() {
		CustomLibraryPickList pcl = new CustomLibraryPickList();
		VisualEditor.DataRow row = pcl.getDefaultValue();

		System.assert(row.getLabel().length() > 0);

		VisualEditor.DynamicPickListRows rows = pcl.getValues();
		System.assert(rows.size() > 0);
	}
}