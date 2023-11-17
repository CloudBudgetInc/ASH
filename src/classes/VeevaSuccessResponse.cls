public class VeevaSuccessResponse {

	public class Errors {
		public String type_Z {get;set;} // in json: type
		public String message {get;set;} 

		public Errors(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'message') {
							message = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Errors consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data_Z {
		public String responseStatus {get;set;} 
		public List<Errors> errors {get;set;} 
		public Data data {get;set;} 

		public Data_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'responseStatus') {
							responseStatus = parser.getText();
						} else if (text == 'errors') {
							errors = arrayOfErrors(parser);
						} else if (text == 'data') {
							data = new Data(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Data_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data {
		public String id {get;set;} 
		public String url {get;set;} 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String responseStatus {get;set;} 
	public List<Data_Z> data {get;set;} 

	public VeevaSuccessResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'responseStatus') {
						responseStatus = parser.getText();
					} else if (text == 'data') {
						data = arrayOfData_Z(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'VeevaSuccessResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static VeevaSuccessResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new VeevaSuccessResponse(parser);
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
	


	private static List<Errors> arrayOfErrors(System.JSONParser p) {
		List<Errors> res = new List<Errors>();
		if (p.getCurrentToken() == null) p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(new Errors(p));
		}
		return res;
	}



	private static List<Data_Z> arrayOfData_Z(System.JSONParser p) {
		List<Data_Z> res = new List<Data_Z>();
		if (p.getCurrentToken() == null) p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
				res.add(new Data_Z(p));
		}
		return res;
	}
}