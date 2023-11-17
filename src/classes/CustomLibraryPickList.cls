global class CustomLibraryPickList extends VisualEditor.DynamicPickList {
	global override VisualEditor.DataRow getDefaultValue(){
		List<ContentWorkspace> libraries = [SELECT Id, Name FROM ContentWorkspace ORDER BY Name ASC];
		VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(libraries[0].Name, String.valueOf(libraries[0].Id));
		return defaultValue;
	}
	global override VisualEditor.DynamicPickListRows getValues() {
		List<ContentWorkspace> libraries = [SELECT Id, Name FROM ContentWorkspace ORDER BY Name ASC];
		VisualEditor.DynamicPickListRows  values = new VisualEditor.DynamicPickListRows();

		if (libraries.size() > 0) {
			for (ContentWorkspace library : libraries)  {
				VisualEditor.DataRow value = new VisualEditor.DataRow(library.Name, String.valueOf(library.Id));
				values.addRow(value);
			}
		}
		return values;
	}
}