global class PayableImageFixerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {
		String empty = '';
        String query = 'SELECT Id, Concur_Key__c, Concur_Id__c ' + 
        'FROM c2g__codaPurchaseInvoice__c ' + 
        'WHERE Image_Processed__c = false AND Concur_Key__c <> :empty';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<c2g__codaPurchaseInvoice__c> scope) { 
        
    	Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://us.api.concursolutions.com/oauth2/v0/token');
		request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		request.setMethod('POST');

		String clientId = 'e8705374-2cc9-43ae-a71c-e3d2af1c21e0';
		String clientSecret = '19e6ec5a-cbd2-4802-aef6-5103e024e3b3';
		String username= 'wsadminPROD@hematology.org';
		String password= 'T<!~h[D7JK[A8"[V';

        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+
            '&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+
            '&username='+EncodingUtil.urlEncode(username,'UTF-8')+
            '&password='+EncodingUtil.urlEncode(password,'UTF-8')+
            '&grant_type=password';
        request.setBody(payload);
        HttpResponse response = http.send(request);

		String accessToken;

        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            //System.debug(response.getBody());
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                parser.nextValue();
                String fieldName = parser.getCurrentName();
                if(fieldName == 'access_token') {
                    String fieldValue = parser.getText();
                    System.debug(fieldName);
                    System.debug(fieldValue);
                    accessToken = fieldValue;
                }
            }
        }
        
        List<Attachment> attachments = new List<Attachment>();
        List<c2g__codaPurchaseInvoice__c> pinsForUpdate = new List<c2g__codaPurchaseInvoice__c>();
        
        for( c2g__codaPurchaseInvoice__c somePayable : scope ) {
            HttpRequest imageFileRequest = new HttpRequest();
            //String imageRequestEndpoint = 'https://us.api.concursolutions.com/api/image/v1.0/invoice/A67102ED581F410DAD77';
            //String imageRequestEndpoint = 'https://us.api.concursolutions.com/api/v3.0/expense/receiptimages/' + somePayable.Concur_Id__c;
            String imageRequestEndpoint = 'https://us.api.concursolutions.com/api/image/v1.0/invoice/' + somePayable.Concur_Id__c;
            System.debug(imageRequestEndpoint);
            imageFileRequest.setEndpoint(imageRequestEndpoint);
            imageFileRequest.setHeader('Content-Type', 'application/xml');
            imageFileRequest.setHeader('Authorization', 'Bearer ' + accessToken);
            imageFileRequest.setMethod('GET');
            HttpResponse secondResponse = http.send(imageFileRequest);
            
            String documentUri;
            
            if (secondResponse.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                    secondResponse.getStatusCode() + ' ' + secondResponse.getStatus());
            } else {
                String imageResponseBody = secondResponse.getBody();
                System.debug(imageResponseBody);
                
                Dom.Document doc = secondResponse.getBodyDocument();
                Dom.XMLNode address = doc.getRootElement();
                for(Dom.XMLNode child : address.getChildElements()) {
                    System.debug(child.getName());
                    String keyName = child.getName();
                    if(keyName == 'Url') {
                        documentUri = child.getText();
                        System.debug(child.getText());
                    }
                }    
			}

            HttpRequest blobFileRequest = new HttpRequest();
            blobFileRequest.setEndpoint(documentUri);
            blobFileRequest.setHeader('Content-Type', 'application/xml');
            blobFileRequest.setHeader('Authorization', 'Bearer ' + accessToken);
            blobFileRequest.setMethod('GET');
            HttpResponse anotherHttpResponse = http.send(blobFileRequest);
            System.debug(anotherHttpResponse);
            Blob body = anotherHttpResponse.getBodyAsBlob();
            System.debug(anotherHttpResponse.getBody());
            Attachment att = new Attachment(Name=somePayable.Concur_Key__c, Body=body, ContentType='application/pdf', ParentId=somePayable.Id);
            attachments.add(att);
            somePayable.Image_Processed__c = true;
            pinsForUpdate.add(somePayable);
        }
		insert attachments;
        update pinsForUpdate;
    }
    
    global void finish(Database.BatchableContext bc) {}
}