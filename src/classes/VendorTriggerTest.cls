@isTest(SeeAllData=true)
public class VendorTriggerTest {
    
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
			if (req.getEndpoint().contains('token')) {
                String fullJson = '{"expires_in":3600,"scope":"openid receipts.read receipts.write receipts.writeonly user.read user.write company.read company.write creditcardaccount.read travelrequest.write mileage.journey.read mileage.journey.writeonly mileage.vehicle.read mileage.vehicle.writeonly mileage.rate.read mileage.rate.writeonly user_read ATTEND CONFIG CONREQ ERECPT EVS EXPRPT CCARD BANK EXTRCT FISVC FOP GHOST IMAGE INSGHT INVPMT INVPO INVTV INVVEN ITINER JOBLOG LIST MTNG NOTIF PAYBAT RCTIMG SUPSVC TAXINV TRVPRF PASSV COMPD EMERG TSAI TMCSP UNUTX TRVPTS TRVREQ TWS COMPANY USER MEDIC","token_type":"Bearer","access_token":"eyJraWQiOiIxNDU1NjE0MDIyIiwiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifQ.eyJjb25jdXIuc2NvcGVzIjpbIm9wZW5pZCIsInJlY2VpcHRzLnJlYWQiLCJyZWNlaXB0cy53cml0ZSIsInJlY2VpcHRzLndyaXRlb25seSIsInVzZXIucmVhZCIsInVzZXIud3JpdGUiLCJjb21wYW55LnJlYWQiLCJjb21wYW55LndyaXRlIiwiY3JlZGl0Y2FyZGFjY291bnQucmVhZCIsInRyYXZlbHJlcXVlc3Qud3JpdGUiLCJtaWxlYWdlLmpvdXJuZXkucmVhZCIsIm1pbGVhZ2Uuam91cm5leS53cml0ZW9ubHkiLCJtaWxlYWdlLnZlaGljbGUucmVhZCIsIm1pbGVhZ2UudmVoaWNsZS53cml0ZW9ubHkiLCJtaWxlYWdlLnJhdGUucmVhZCIsIm1pbGVhZ2UucmF0ZS53cml0ZW9ubHkiLCJ1c2VyX3JlYWQiLCJBVFRFTkQiLCJDT05GSUciLCJDT05SRVEiLCJFUkVDUFQiLCJFVlMiLCJFWFBSUFQiLCJDQ0FSRCIsIkJBTksiLCJFWFRSQ1QiLCJGSVNWQyIsIkZPUCIsIkdIT1NUIiwiSU1BR0UiLCJJTlNHSFQiLCJJTlZQTVQiLCJJTlZQTyIsIklOVlRWIiwiSU5WVkVOIiwiSVRJTkVSIiwiSk9CTE9HIiwiTElTVCIsIk1UTkciLCJOT1RJRiIsIlBBWUJBVCIsIlJDVElNRyIsIlNVUFNWQyIsIlRBWElOViIsIlRSVlBSRiIsIlBBU1NWIiwiQ09NUEQiLCJFTUVSRyIsIlRTQUkiLCJUTUNTUCIsIlVOVVRYIiwiVFJWUFRTIiwiVFJWUkVRIiwiVFdTIiwiQ09NUEFOWSIsIlVTRVIiLCJNRURJQyJdLCJhdWQiOiIqIiwiY29uY3VyLnByb2ZpbGUiOiJodHRwczovL3VzLmFwaS5jb25jdXJzb2x1dGlvbnMuY29tL3Byb2ZpbGUvdjEvcHJpbmNpcGFscy9lN2EyNzk2Yi05NjkyLTRiZDUtYjFlMy1lYjAwOWVlYjhkOTgiLCJjb25jdXIudmVyc2lvbiI6MywiY29uY3VyLnR5cGUiOiJ1c2VyIiwiY29tcGFueSI6ImU1Y2VlMTYwLTRhODItNDNlYi05YzVkLTIwNGI0OTBmNjg1YiIsImNvbmN1ci5hcHAiOiJodHRwczovL3VzLmFwaS5jb25jdXJzb2x1dGlvbnMuY29tL3Byb2ZpbGUvdjEvYXBwcy9lODcwNTM3NC0yY2M5LTQzYWUtYTcxYy1lM2QyYWYxYzIxZTAiLCJzdWIiOiJlN2EyNzk2Yi05NjkyLTRiZDUtYjFlMy1lYjAwOWVlYjhkOTgiLCJpc3MiOiJodHRwczovL3VzLmFwaS5jb25jdXJzb2x1dGlvbnMuY29tIiwiZXhwIjoxNjMxOTgxNzMxLCJjb25jdXIuYXBwSWQiOiJlODcwNTM3NC0yY2M5LTQzYWUtYTcxYy1lM2QyYWYxYzIxZTAiLCJuYmYiOjE2MzE5NzgxMjEsImlhdCI6MTYzMTk3ODEzMSwiY29uY3VyLmNvbXBhbnkiOiJlNWNlZTE2MC00YTgyLTQzZWItOWM1ZC0yMDRiNDkwZjY4NWIifQ.nfeQkckzZBD0MT6Ieg6Xw_Ueq4XKXpRC_AhEi059UQXI6R9BiAnCh3usLS2fynFX5Ut9XvPk8geb6BoBN8G2kFZpbSg-2q9xPJcSaGwrrMuOJ3VWduomkXxuaxip6EmHKkCRUNRAHwLoqgJdA36adr6A8YHFXyhwvEub0NUfzhnPAsiiHvUSfsYuO-Y8qfK8TJJQpDxB00THavOoCqg5o2VWLX45ZuUrSsF1wQb_FX1qLL9Tm5APfR8DPgNR3BfeuAVIUN2tHp6qVoiVwzzU7cBA6tYzAQEUy0tkPr7zvdj7TmKI1V49Iy-oB-I-V_0F5BUBtHWd8AITY_QaD4dBqQ","refresh_token":"3pfo2en3qndngnz93m7ru21264vae7","refresh_expires_in":1647530131,"geolocation":"https://us.api.concursolutions.com","id_token":"eyJraWQiOiIxNDU1NjE0MDIyIiwiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJlODcwNTM3NC0yY2M5LTQzYWUtYTcxYy1lM2QyYWYxYzIxZTAiLCJjb25jdXIucHJvZmlsZSI6Imh0dHBzOi8vdXMuYXBpLmNvbmN1cnNvbHV0aW9ucy5jb20vcHJvZmlsZS92MS9wcmluY2lwYWxzL2U3YTI3OTZiLTk2OTItNGJkNS1iMWUzLWViMDA5ZWViOGQ5OCIsImNvbmN1ci52ZXJzaW9uIjozLCJjb25jdXIudHlwZSI6InVzZXIiLCJzdWIiOiJlN2EyNzk2Yi05NjkyLTRiZDUtYjFlMy1lYjAwOWVlYjhkOTgiLCJpc3MiOiJodHRwczovL3VzLmFwaS5jb25jdXJzb2x1dGlvbnMuY29tIiwiZXhwIjoxNjMxOTgxNzMxLCJuYmYiOjE2MzE5NzgxMjEsImlhdCI6MTYzMTk3ODEzMSwiY29uY3VyLmNvbXBhbnkiOiJlNWNlZTE2MC00YTgyLTQzZWItOWM1ZC0yMDRiNDkwZjY4NWIifQ.PldEQJAhzL90ZdDjYV7ip1SOHGKMY7fetbLmFC01maGjpMADG5me-KZ62m6EHrSB0D97gHsAjvVaIA2o3K5rh7i2FzXp74YtEHJOD5sr56g8ZwEb7xPYl6NbnR7IErqSFT5o4vOCLDJruG5zn-CvAhnmnvAVuKsUFGbOWveRp15-dtiZV3LmFw1a9ua2d03rw5PKx2EL6Sm6__F95D_zYfHFPxlLRuMcuPogEhK2osHb2TmBS6wL1X1DIy72vfuLITXcHoa-IHvLZq2uUBO2WSIrwK4xdc9I6Q6JItW6B3hUKQoyMBZoaWXfipHOxuDTAbxj6oO1YMrjr8FKXLcLyA"}';
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'text/json');
                res.setBody(fullJson);
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().contains('vendor') && req.getMethod().contains('PUT')) {
                String xmlBody = '<Vendors xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Items /><NextPage xsi:nil="true" /><TotalCount xsi:nil="true" /><RequestRunSummary>Processed 1 record(s). </RequestRunSummary></Vendors>';
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/xml; charset=utf-8');
                res.setBody(xmlBody);
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().contains('vendor') && req.getMethod().contains('POST')) {
				String xmlBody = '<Vendors xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Items /><NextPage xsi:nil="true" /><TotalCount xsi:nil="true" /><RequestRunSummary>Processed 1 record(s). </RequestRunSummary></Vendors>';
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/xml; charset=utf-8');
                res.setBody(xmlBody);
                res.setStatusCode(200);
                return res;                
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
    
	static testMethod void testNewVendorTrigger() {
        Test.startTest();
		Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
        Account someNewVendor = new Account();
        someNewVendor.Name = 'Farzwillow Farms';
        someNewVendor.Vendor_Key__c = 'FARZ';
        someNewVendor.RecordTypeId = vendorRecordTypeId;
        insert someNewVendor;
        Account theNewAccount = [SELECT Id, Vendor_ID__c, c2g__CODAAccountTradingCurrency__c, 
								c2g__CODAAccountsPayableControl__r.c2g__ReportingCode__c,
                                c2g__CODABaseDate1__c,c2g__CODADaysOffset1__c,
                                c2g__CODADimension1__r.c2g__ReportingCode__c, 
                                c2g__CODADimension2__r.c2g__ReportingCode__c,
                                c2g__CODADimension3__r.c2g__ReportingCode__c, 
                                c2g__CODADimension4__r.c2g__ReportingCode__c FROM Account 
                                WHERE Account.Name = 'Farzwillow Farms'];
        System.assertEquals(theNewAccount.Vendor_ID__c, 'FARZ01');
        System.assertEquals(theNewAccount.c2g__CODAAccountTradingCurrency__c, 'USD');
        System.assertEquals(theNewAccount.c2g__CODAAccountsPayableControl__r.c2g__ReportingCode__c , '2040');
        System.assertEquals(theNewAccount.c2g__CODABaseDate1__c, 'Invoice Date');
        System.assertEquals(theNewAccount.c2g__CODADaysOffset1__c, 30);
		System.assertEquals(theNewAccount.c2g__CODADimension1__r.c2g__ReportingCode__c, '100');
        System.assertEquals(theNewAccount.c2g__CODADimension2__r.c2g__ReportingCode__c, '000');
        System.assertEquals(theNewAccount.c2g__CODADimension3__r.c2g__ReportingCode__c, '000');
        System.assertEquals(theNewAccount.c2g__CODADimension4__r.c2g__ReportingCode__c, '00');
        Test.stopTest();
    }

    static testMethod void testVendorApprovalTrigger() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account someNewVendor = new Account(Name='Fzzzwillow Farms', Vendor_Key__c = 'FZZZ');
		Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();      
        someNewVendor.RecordTypeId = vendorRecordTypeId;
        insert someNewVendor;        
        Account thatAccount = [SELECT Id FROM Account WHERE Name = 'Fzzzwillow Farms'];
        thatAccount.Vendor_Status__c = 'Approved';
        update thatAccount;        
        List<Concur_Log__c> someLogs = [SELECT Id, Vendor_ID__c, Type__c, Event_Date_Time__c FROM Concur_Log__c 
                              WHERE Vendor_ID__c LIKE 'FZZZ%' AND Type__c = 'Insert'];
        System.assertEquals(1, someLogs.size());
        Test.stopTest();
    }
    
    static testMethod void testVendorUpdateTrigger() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account someExistingVendor = [SELECT Name, Remit_Address_1__c, Remit_City__c, 
            Remit_State__c, Remit_Postal_Code__c FROM Account WHERE Vendor_Id__c = 'TRIS01'];
        someExistingVendor.Remit_Address_1__c = '234 Main Road';
        update someExistingVendor;         
        List<Concur_Log__c> someLogs = [SELECT Id, Vendor_ID__c, Type__c, Event_Date_Time__c FROM Concur_Log__c 
                              WHERE Vendor_ID__c = 'TRIS01' AND Type__c = 'Update' AND CreatedDate = TODAY];
        System.assertEquals(1, someLogs.size());
        Test.stopTest();
    }
    
    static testMethod void testVendorDeleteTrigger() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account someNewVendor = new Account(Name='Bzzzwillow Farms', Vendor_Key__c = 'BZZZ');
		Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();      
        someNewVendor.RecordTypeId = vendorRecordTypeId;
        insert someNewVendor;
		delete someNewVendor;
        List<Legacy_Vendor__c> someLegacyVendorRecord = [SELECT Id, Vendor_ID__c FROM Legacy_Vendor__c 
                              WHERE Vendor_ID__c = 'BZZZ01' AND CreatedDate = TODAY];
        System.assertEquals(1, someLegacyVendorRecord.size());
        Test.stopTest();
    }
}