global class ExampleCalloutMock implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		if (req.getBody().contains('username')) {
			res.setBody('{' + 
			'"sessionId": "0F7CAE4ABB13CE48759CC07D468A2B7CCF6AE5C3EF1733F9E5FED597FDC6714E1683FD4365CA3FC0F5FC6B91F81BDE14FA1C4E79062D18A5E78CE9904D8F9D53",' +
			'"data": [{ "data": { "responseStatus": "SUCCESS", "id": "V0B000000000Q05" } }]}');
		} else {
			res.setBody('{\"responseStatus\":\"SUCCESS\",\"data\":[{\"responseStatus\":\"SUCCESS\", \"data\": {'+
			'                \"id\": \"V0B000000000Q05\",'+
			'                \"url\": \"/api/v20.1/vobjects/person__sys/V0B000000000Q05\"'+
			'            }}]}');
		}
		return res;
	}
}