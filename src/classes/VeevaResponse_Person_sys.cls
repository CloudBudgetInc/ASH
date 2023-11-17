public class VeevaResponse_Person_sys {

	public class Fields {
		public String label {get;set;} 
		public String type_Z {get;set;} // in json: type
		public Boolean required {get;set;} 
		public Boolean unique {get;set;} 
		public String name {get;set;} 
		public List<String> status {get;set;} 
		public Boolean encrypted {get;set;} 
		public Integer max_length {get;set;} 
		public String picklist {get;set;} 

		public Fields(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'label') {
							label = parser.getText();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'required') {
							required = parser.getBooleanValue();
						} else if (text == 'unique') {
							unique = parser.getBooleanValue();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'status') {
							status = arrayOfString(parser);
						} else if (text == 'encrypted') {
							encrypted = parser.getBooleanValue();
						} else if (text == 'max_length') {
							max_length = parser.getIntegerValue();
						} else if (text == 'picklist') {
							picklist = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Fields consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Object_Z {
		public String name {get;set;} 
		public String label {get;set;} 
		public String label_plural {get;set;} 

		public Object_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'label') {
							label = parser.getText();
						} else if (text == 'label_plural') {
							label_plural = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Object_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String responseStatus {get;set;} 
	public QueryDescribe queryDescribe {get;set;} 
	public ResponseDetails responseDetails {get;set;} 
	public List<Data> data {get;set;} 

	public VeevaResponse_Person_sys(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'responseStatus') {
						responseStatus = parser.getText();
					} else if (text == 'queryDescribe') {
						queryDescribe = new QueryDescribe(parser);
					} else if (text == 'responseDetails') {
						responseDetails = new ResponseDetails(parser);
					} else if (text == 'data') {
						data = arrayOfData(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'VeevaResponse_Person_sys consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class ResponseDetails {
		public Integer limit_Z {get;set;} // in json: limit
		public Integer offset {get;set;} 
		public Integer size {get;set;} 
		public Integer total {get;set;} 

		public ResponseDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'limit') {
							limit_Z = parser.getIntegerValue();
						} else if (text == 'offset') {
							offset = parser.getIntegerValue();
						} else if (text == 'size') {
							size = parser.getIntegerValue();
						} else if (text == 'total') {
							total = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'ResponseDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data {
		public String name_v {get;set;} 
		public String id {get;set;} 
		public String email_sys {get;set;} 
		public String last_name_sys {get;set;} 
		public String first_name_sys {get;set;} 
		public List<String> status_v {get;set;} 
		public Boolean sf_inactive_c {get;set;} 
		public Integer created_by_v {get;set;} 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name__v') {
							name_v = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'email__sys') {
							email_sys = parser.getText();
						} else if (text == 'last_name__sys') {
							last_name_sys = parser.getText();
						} else if (text == 'first_name__sys') {
							first_name_sys = parser.getText();
						} else if (text == 'status__v') {
							status_v = arrayOfString(parser);
						} else if (text == 'sf_inactive__c') {
							sf_inactive_c = parser.getBooleanValue();
						} else if (text == 'created_by__v') {
							created_by_v = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class QueryDescribe {
		public Object_Z object_Z {get;set;} // in json: object
		public List<Fields> fields {get;set;} 

		public QueryDescribe(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'object') {
							object_Z = new Object_Z(parser);
						} else if (text == 'fields') {
							fields = arrayOfFields(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'QueryDescribe consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public static VeevaResponse_Person_sys parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new VeevaResponse_Person_sys(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

	private static List<String> arrayOfString(System.JSONParser p) {
		List<String> res = new List<String>();
		if (p.getCurrentToken() == null) p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(p.getText());
		}
		return res;
	}

	private static List<Fields> arrayOfFields(System.JSONParser p) {
		List<Fields> res = new List<Fields>();
		if (p.getCurrentToken() == null) p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(new Fields(p));
		}
		return res;
	}

	private static List<Data> arrayOfData(System.JSONParser p) {
		List<Data> res = new List<Data>();
		if (p.getCurrentToken() == null) p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(new Data(p));
		}
		return res;
	}
}