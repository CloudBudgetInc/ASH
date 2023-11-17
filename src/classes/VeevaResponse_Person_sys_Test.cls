@IsTest
public class VeevaResponse_Person_sys_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'    \"responseStatus\": \"SUCCESS\",'+
		'    \"queryDescribe\": {'+
		'        \"object\": {'+
		'            \"name\": \"person__sys\",'+
		'            \"label\": \"Person\",'+
		'            \"label_plural\": \"Persons\"'+
		'        },'+
		'        \"fields\": ['+
		'            {'+
		'                \"label\": \"Name\",'+
		'                \"type\": \"String\",'+
		'                \"required\": true,'+
		'                \"unique\": false,'+
		'                \"name\": \"name__v\",'+
		'                \"status\": ['+
		'                    \"active__v\"'+
		'                ],'+
		'                \"encrypted\": false,'+
		'                \"max_length\": 128'+
		'            },'+
		'            {'+
		'                \"label\": \"ID\",'+
		'                \"type\": \"ID\",'+
		'                \"required\": false,'+
		'                \"name\": \"id\",'+
		'                \"status\": ['+
		'                    \"active__v\"'+
		'                ],'+
		'                \"encrypted\": false'+
		'            },'+
		'            {'+
		'                \"label\": \"Email\",'+
		'                \"type\": \"String\",'+
		'                \"required\": false,'+
		'                \"unique\": false,'+
		'                \"name\": \"email__sys\",'+
		'                \"status\": ['+
		'                    \"active__v\"'+
		'                ],'+
		'                \"encrypted\": false,'+
		'                \"max_length\": 120'+
		'            },'+
		'            {'+
		'                \"label\": \"Last Name\",'+
		'                \"type\": \"String\",'+
		'                \"required\": true,'+
		'                \"unique\": false,'+
		'                \"name\": \"last_name__sys\",'+
		'                \"status\": ['+
		'                    \"active__v\"'+
		'                ],'+
		'                \"encrypted\": false,'+
		'                \"max_length\": 100'+
		'            },'+
		'            {'+
		'                \"label\": \"First Name\",'+
		'                \"type\": \"String\",'+
		'                \"required\": false,'+
		'                \"unique\": false,'+
		'                \"name\": \"first_name__sys\",'+
		'                \"status\": ['+
		'                    \"active__v\"'+
		'                ],'+
		'                \"encrypted\": false,'+
		'                \"max_length\": 100'+
		'            },'+
		'            {'+
		'                \"label\": \"Status\",'+
		'                \"type\": \"Picklist\",'+
		'                \"required\": true,'+
		'                \"unique\": false,'+
		'                \"name\": \"status__v\",'+
		'                \"status\": ['+
		'                    \"active__v\"'+
		'                ],'+
		'                \"picklist\": \"default_status__v\",'+
		'                \"encrypted\": false'+
		'            },'+
		'            {'+
		'                \"label\": \"SF Inactive?\",'+
		'                \"type\": \"Boolean\",'+
		'                \"required\": false,'+
		'                \"name\": \"sf_inactive__c\",'+
		'                \"status\": ['+
		'                    \"active__v\"'+
		'                ],'+
		'                \"encrypted\": false'+
		'            },'+
		'            {'+
		'                \"label\": \"Created By\",'+
		'                \"type\": \"Object\",'+
		'                \"required\": false,'+
		'                \"unique\": false,'+
		'                \"name\": \"created_by__v\",'+
		'                \"status\": ['+
		'                    \"active__v\"'+
		'                ],'+
		'                \"encrypted\": false'+
		'            }'+
		'        ]'+
		'    },'+
		'    \"responseDetails\": {'+
		'        \"limit\": 1000,'+
		'        \"offset\": 0,'+
		'        \"size\": 1,'+
		'        \"total\": 1'+
		'    },'+
		'    \"data\": ['+
		'        {'+
		'            \"name__v\": \"Test 6 User\",'+
		'            \"id\": \"V0B000000000O10\",'+
		'            \"email__sys\": \"test6@gmail.com\",'+
		'            \"last_name__sys\": \"User\",'+
		'            \"first_name__sys\": \"Test 6\",'+
		'            \"status__v\": ['+
		'                \"active__v\"'+
		'            ],'+
		'            \"sf_inactive__c\": false,'+
		'            \"created_by__v\": 5265815'+
		'        }'+
		'    ]'+
		'}';
		VeevaResponse_Person_sys r = VeevaResponse_Person_sys.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaResponse_Person_sys.Fields objFields = new VeevaResponse_Person_sys.Fields(System.JSON.createParser(json));
		System.assert(objFields != null);
		System.assert(objFields.label == null);
		System.assert(objFields.type_Z == null);
		System.assert(objFields.required == null);
		System.assert(objFields.unique == null);
		System.assert(objFields.name == null);
		System.assert(objFields.status == null);
		System.assert(objFields.encrypted == null);
		System.assert(objFields.max_length == null);
		System.assert(objFields.picklist == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaResponse_Person_sys.Object_Z objObject_Z = new VeevaResponse_Person_sys.Object_Z(System.JSON.createParser(json));
		System.assert(objObject_Z != null);
		System.assert(objObject_Z.name == null);
		System.assert(objObject_Z.label == null);
		System.assert(objObject_Z.label_plural == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaResponse_Person_sys objVeevaResponse_Person_sys = new VeevaResponse_Person_sys(System.JSON.createParser(json));
		System.assert(objVeevaResponse_Person_sys != null);
		System.assert(objVeevaResponse_Person_sys.responseStatus == null);
		System.assert(objVeevaResponse_Person_sys.queryDescribe == null);
		System.assert(objVeevaResponse_Person_sys.responseDetails == null);
		System.assert(objVeevaResponse_Person_sys.data == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaResponse_Person_sys.ResponseDetails objResponseDetails = new VeevaResponse_Person_sys.ResponseDetails(System.JSON.createParser(json));
		System.assert(objResponseDetails != null);
		System.assert(objResponseDetails.limit_Z == null);
		System.assert(objResponseDetails.offset == null);
		System.assert(objResponseDetails.size == null);
		System.assert(objResponseDetails.total == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaResponse_Person_sys.Data objData = new VeevaResponse_Person_sys.Data(System.JSON.createParser(json));
		System.assert(objData != null);
		System.assert(objData.name_v == null);
		System.assert(objData.id == null);
		System.assert(objData.email_sys == null);
		System.assert(objData.last_name_sys == null);
		System.assert(objData.first_name_sys == null);
		System.assert(objData.status_v == null);
		System.assert(objData.sf_inactive_c == null);
		System.assert(objData.created_by_v == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		VeevaResponse_Person_sys.QueryDescribe objQueryDescribe = new VeevaResponse_Person_sys.QueryDescribe(System.JSON.createParser(json));
		System.assert(objQueryDescribe != null);
		System.assert(objQueryDescribe.object_Z == null);
		System.assert(objQueryDescribe.fields == null);
	}
}