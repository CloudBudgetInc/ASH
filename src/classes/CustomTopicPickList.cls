global class CustomTopicPickList extends VisualEditor.DynamicPickList{
	global override VisualEditor.DataRow getDefaultValue(){
		List<Topic> topics = [SELECT Id, Name FROM Topic WHERE NetworkId = '0DB3u000000g0P4GAI' ORDER BY Name];
		VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(topics[0].Name, topics[0].Name);
		return defaultValue;
	}
	global override VisualEditor.DynamicPickListRows getValues() {
		List<Topic> topics = [SELECT Id, Name FROM Topic WHERE NetworkId = '0DB3u000000g0P4GAI' ORDER BY Name];
		VisualEditor.DynamicPickListRows  values = new VisualEditor.DynamicPickListRows();

		if (topics.size() > 0) {
			for (Topic topic : topics)  {
				VisualEditor.DataRow value = new VisualEditor.DataRow(topic.Name, topic.Name);
				values.addRow(value);
			}
		}
		return values;
	}
}