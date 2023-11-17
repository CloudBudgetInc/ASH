@IsTest
public class VeevaSuccessResponseTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{\"responseStatus\":\"SUCCESS\",\"data\":[{\"responseStatus\":\"FAILURE\",\"errors\":[{\"type\":\"OPERATION_NOT_ALLOWED\",\"message\":\"Another resource already exists with [name__v=Test Org]\"}]}]}';
		VeevaSuccessResponse r = VeevaSuccessResponse.parse(json);
		System.assert(r != null);

		String successJson = '{\"responseStatus\":\"SUCCESS\",\"data\":[{\"responseStatus\":\"SUCCESS\", \"data\": {'+
		'                \"id\": \"V0B000000000Q05\",'+
		'                \"url\": \"/api/v20.1/vobjects/person__sys/V0B000000000Q05\"'+
		'            }}]}';
		VeevaSuccessResponse res = VeevaSuccessResponse.parse(successJson);
		System.assert(res != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaSuccessResponse.Errors objErrors = new VeevaSuccessResponse.Errors(System.JSON.createParser(json));
		System.assert(objErrors != null);
		System.assert(objErrors.type_Z == null);
		System.assert(objErrors.message == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaSuccessResponse.Data_Z objData_Z = new VeevaSuccessResponse.Data_Z(System.JSON.createParser(json));
		System.assert(objData_Z != null);
		System.assert(objData_Z.responseStatus == null);
		System.assert(objData_Z.errors == null);
		System.assert(objData_Z.data == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaSuccessResponse.Data objData = new VeevaSuccessResponse.Data(System.JSON.createParser(json));
		System.assert(objData != null);
		System.assert(objData.id == null);
		System.assert(objData.url == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaSuccessResponse objVeevaSuccessResponse = new VeevaSuccessResponse(System.JSON.createParser(json));
		System.assert(objVeevaSuccessResponse != null);
		System.assert(objVeevaSuccessResponse.responseStatus == null);
		System.assert(objVeevaSuccessResponse.data == null);
	}
}