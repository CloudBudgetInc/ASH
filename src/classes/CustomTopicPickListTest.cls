@IsTest(SeeAllData=true)
	public with sharing class CustomTopicPickListTest {
		@IsTest(SeeAllData=true)
		public static void testCustomTopicPickList() {
			CustomTopicPickList pcl = new CustomTopicPickList();
			VisualEditor.DataRow row = pcl.getDefaultValue();

			System.assert(row.getLabel().length() > 0);

			VisualEditor.DynamicPickListRows rows = pcl.getValues();
			System.assert(rows.size() > 0);
		}
}