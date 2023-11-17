@isTest(SeeAllData=true)
public class PayableImageFixerInvokableHelperTest {
    
    public static testmethod void testBatchable() {
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        c2g__codaPurchaseInvoice__c somePin = new c2g__codaPurchaseInvoice__c();
        somePin.c2g__Account__c = provider.getVendor('TRIS01').Id;
        somePin.c2g__AccountInvoiceNumber__c = 'DAHDAHDAH';
        somePin.Reference_Number__c = 'DEEPDEEPDEEP';
        somePin.Batch_Number__c = 'FLERK';
        somePin.c2g__InvoiceDate__c = System.today();
        somePin.Concur_Id__c = '0BD8FFBA82B649D0B04A';
        somePin.Concur_Key__c = '439022';
        somePin.c2g__OwnerCompany__c = provider.getCompany('ASH');
        somePin.Source__c = 'Concur';
        somePin.Image_Processed__c = false;
        insert somePin;        
    
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());  
        List<String> params = new List<String>();
        params.add('1');
        List<List<String>>  outerParams = new List<List<String>>();
        outerParams.add(params);
        PayableImageFixerInvokableHelper.fetchPayableInvoiceImages(outerParams);
        Test.StopTest();
        
        List<AsyncApexJob> batchJobs = [SELECT Id, Status FROM AsyncApexJob 
                                        WHERE ApexClass.Name = 'PayableImageFixerBatch' 
                                        AND JobType = 'BatchApex'
                                        AND CreatedDate = TODAY];        
        System.assert(batchJobs.size() > 0, 'Unexpected number of batch jobs ran: ' + batchJobs);     
    }
    
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
			if (req.getEndpoint().contains('token')) {
                String fullJson = '{"expires_in":3600,"scope":"openid receipts.read receipts.write receipts.writeonly user.read user.write company.read company.write creditcardaccount.read travelrequest.write mileage.journey.read mileage.journey.writeonly mileage.vehicle.read mileage.vehicle.writeonly mileage.rate.read mileage.rate.writeonly user_read ATTEND CONFIG CONREQ ERECPT EVS EXPRPT CCARD BANK EXTRCT FISVC FOP GHOST IMAGE INSGHT INVPMT INVPO INVTV INVVEN ITINER JOBLOG LIST MTNG NOTIF PAYBAT RCTIMG SUPSVC TAXINV TRVPRF PASSV COMPD EMERG TSAI TMCSP UNUTX TRVPTS TRVREQ TWS COMPANY USER MEDIC","token_type":"Bearer","access_token":"eyJraWQiOiIxNDU1NjE0MDIyIiwiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifQ.eyJjb25jdXIuc2NvcGVzIjpbIm9wZW5pZCIsInJlY2VpcHRzLnJlYWQiLCJyZWNlaXB0cy53cml0ZSIsInJlY2VpcHRzLndyaXRlb25seSIsInVzZXIucmVhZCIsInVzZXIud3JpdGUiLCJjb21wYW55LnJlYWQiLCJjb21wYW55LndyaXRlIiwiY3JlZGl0Y2FyZGFjY291bnQucmVhZCIsInRyYXZlbHJlcXVlc3Qud3JpdGUiLCJtaWxlYWdlLmpvdXJuZXkucmVhZCIsIm1pbGVhZ2Uuam91cm5leS53cml0ZW9ubHkiLCJtaWxlYWdlLnZlaGljbGUucmVhZCIsIm1pbGVhZ2UudmVoaWNsZS53cml0ZW9ubHkiLCJtaWxlYWdlLnJhdGUucmVhZCIsIm1pbGVhZ2UucmF0ZS53cml0ZW9ubHkiLCJ1c2VyX3JlYWQiLCJBVFRFTkQiLCJDT05GSUciLCJDT05SRVEiLCJFUkVDUFQiLCJFVlMiLCJFWFBSUFQiLCJDQ0FSRCIsIkJBTksiLCJFWFRSQ1QiLCJGSVNWQyIsIkZPUCIsIkdIT1NUIiwiSU1BR0UiLCJJTlNHSFQiLCJJTlZQTVQiLCJJTlZQTyIsIklOVlRWIiwiSU5WVkVOIiwiSVRJTkVSIiwiSk9CTE9HIiwiTElTVCIsIk1UTkciLCJOT1RJRiIsIlBBWUJBVCIsIlJDVElNRyIsIlNVUFNWQyIsIlRBWElOViIsIlRSVlBSRiIsIlBBU1NWIiwiQ09NUEQiLCJFTUVSRyIsIlRTQUkiLCJUTUNTUCIsIlVOVVRYIiwiVFJWUFRTIiwiVFJWUkVRIiwiVFdTIiwiQ09NUEFOWSIsIlVTRVIiLCJNRURJQyJdLCJhdWQiOiIqIiwiY29uY3VyLnByb2ZpbGUiOiJodHRwczovL3VzLmFwaS5jb25jdXJzb2x1dGlvbnMuY29tL3Byb2ZpbGUvdjEvcHJpbmNpcGFscy9lN2EyNzk2Yi05NjkyLTRiZDUtYjFlMy1lYjAwOWVlYjhkOTgiLCJjb25jdXIudmVyc2lvbiI6MywiY29uY3VyLnR5cGUiOiJ1c2VyIiwiY29tcGFueSI6ImU1Y2VlMTYwLTRhODItNDNlYi05YzVkLTIwNGI0OTBmNjg1YiIsImNvbmN1ci5hcHAiOiJodHRwczovL3VzLmFwaS5jb25jdXJzb2x1dGlvbnMuY29tL3Byb2ZpbGUvdjEvYXBwcy9lODcwNTM3NC0yY2M5LTQzYWUtYTcxYy1lM2QyYWYxYzIxZTAiLCJzdWIiOiJlN2EyNzk2Yi05NjkyLTRiZDUtYjFlMy1lYjAwOWVlYjhkOTgiLCJpc3MiOiJodHRwczovL3VzLmFwaS5jb25jdXJzb2x1dGlvbnMuY29tIiwiZXhwIjoxNjMxOTgxNzMxLCJjb25jdXIuYXBwSWQiOiJlODcwNTM3NC0yY2M5LTQzYWUtYTcxYy1lM2QyYWYxYzIxZTAiLCJuYmYiOjE2MzE5NzgxMjEsImlhdCI6MTYzMTk3ODEzMSwiY29uY3VyLmNvbXBhbnkiOiJlNWNlZTE2MC00YTgyLTQzZWItOWM1ZC0yMDRiNDkwZjY4NWIifQ.nfeQkckzZBD0MT6Ieg6Xw_Ueq4XKXpRC_AhEi059UQXI6R9BiAnCh3usLS2fynFX5Ut9XvPk8geb6BoBN8G2kFZpbSg-2q9xPJcSaGwrrMuOJ3VWduomkXxuaxip6EmHKkCRUNRAHwLoqgJdA36adr6A8YHFXyhwvEub0NUfzhnPAsiiHvUSfsYuO-Y8qfK8TJJQpDxB00THavOoCqg5o2VWLX45ZuUrSsF1wQb_FX1qLL9Tm5APfR8DPgNR3BfeuAVIUN2tHp6qVoiVwzzU7cBA6tYzAQEUy0tkPr7zvdj7TmKI1V49Iy-oB-I-V_0F5BUBtHWd8AITY_QaD4dBqQ","refresh_token":"3pfo2en3qndngnz93m7ru21264vae7","refresh_expires_in":1647530131,"geolocation":"https://us.api.concursolutions.com","id_token":"eyJraWQiOiIxNDU1NjE0MDIyIiwiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJlODcwNTM3NC0yY2M5LTQzYWUtYTcxYy1lM2QyYWYxYzIxZTAiLCJjb25jdXIucHJvZmlsZSI6Imh0dHBzOi8vdXMuYXBpLmNvbmN1cnNvbHV0aW9ucy5jb20vcHJvZmlsZS92MS9wcmluY2lwYWxzL2U3YTI3OTZiLTk2OTItNGJkNS1iMWUzLWViMDA5ZWViOGQ5OCIsImNvbmN1ci52ZXJzaW9uIjozLCJjb25jdXIudHlwZSI6InVzZXIiLCJzdWIiOiJlN2EyNzk2Yi05NjkyLTRiZDUtYjFlMy1lYjAwOWVlYjhkOTgiLCJpc3MiOiJodHRwczovL3VzLmFwaS5jb25jdXJzb2x1dGlvbnMuY29tIiwiZXhwIjoxNjMxOTgxNzMxLCJuYmYiOjE2MzE5NzgxMjEsImlhdCI6MTYzMTk3ODEzMSwiY29uY3VyLmNvbXBhbnkiOiJlNWNlZTE2MC00YTgyLTQzZWItOWM1ZC0yMDRiNDkwZjY4NWIifQ.PldEQJAhzL90ZdDjYV7ip1SOHGKMY7fetbLmFC01maGjpMADG5me-KZ62m6EHrSB0D97gHsAjvVaIA2o3K5rh7i2FzXp74YtEHJOD5sr56g8ZwEb7xPYl6NbnR7IErqSFT5o4vOCLDJruG5zn-CvAhnmnvAVuKsUFGbOWveRp15-dtiZV3LmFw1a9ua2d03rw5PKx2EL6Sm6__F95D_zYfHFPxlLRuMcuPogEhK2osHb2TmBS6wL1X1DIy72vfuLITXcHoa-IHvLZq2uUBO2WSIrwK4xdc9I6Q6JItW6B3hUKQoyMBZoaWXfipHOxuDTAbxj6oO1YMrjr8FKXLcLyA"}';
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'text/json');
                res.setBody(fullJson);
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().contains('image') && req.getMethod().contains('GET')) {
                String xmlBody = '<Image xmlns="http://www.concursolutions.com/api/image/2011/02" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><Id>0BD8FFBA82B649D0B04A</Id><Url>https://www-us.api.concursolutions.com/imaging/web/us1/file/p0067304f7i5/7610ABD392D2A5CDB1C3A2FB2FB2BE4436AF6C362FBD5A30B618EB796B9AE73DEF9AFA1D604D37850EFD00AD8A17CA68BCBD281FBC96D3135CAFF69D4AD1248D3D4FE7454AH07EF472F5513C914B5D4A8974B09052F?id=0BD8FFBA82B649D0B04A&amp;e=p0067304f7i5&amp;t=AN&amp;s=ConcurConnect</Url></Image>';
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/xml; charset=utf-8');
                res.setBody(xmlBody);
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().contains('imaging') && req.getMethod().contains('GET')) {
	            String xmlBody = '<Image xmlns="http://www.concursolutions.com/api/image/2011/02" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><Id>09801A22785C48F28DF3</Id><Url>https://www-us.api.concursolutions.com/imaging/web/us1/file/p0067304f7i5/7C05FD787E45C815C6099B801C11090757D75516459693DE96B78AD75F578415410A3985F32B708F398003F5AF2DE005A3A89A8E26DE55ACBDA985F6AEEE66993A26F72706H2254B9A806DA7D2C544ECDAE6F0BF0A9?id=09801A22785C48F28DF3&amp;e=p0067304f7i5&amp;t=AN&am</Url></Image>';
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/xml; charset=utf-8');
                res.setBody(xmlBody);
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().contains('file') && req.getMethod().contains('GET')) {
	            String xmlBody = 'nope';
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
}