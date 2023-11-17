public class VeevaCalloutClass {

  public static HttpResponse authenticateVeeva(String apiEndpoint) {
    String username = 'SalesforceIntegration@ashrc.org';
    String password = 'Ashrc2021';
    String sessionId = '';

    Http http = new Http();
    HttpRequest req = new HttpRequest();
    String endpoint = apiEndpoint + 'auth';
    req.setEndPoint(endpoint);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    req.setHeader('Accept', 'application/json');
    req.setBody('username=' + username + '&password=' + password);
    HttpResponse res = http.send(req);
    return res;
  }

  public static HttpResponse createVeevaObject(String apiEndpoint, String sessionId, String objectName, String body) {
    String endpoint = apiEndpoint + 'vobjects/' + objectName;
    Http http = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndPoint(endpoint);
    req.setMethod('POST');
    req.setHeader('Authorization', sessionId);
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Accept', 'application/json');
    req.setBody('[' + body + ']');
    HttpResponse res = http.send(req);
    return res;
  }

  public static HttpResponse updateVeevaObject(String apiEndpoint, String sessionId, String objectName, String body) {
    String endpoint = apiEndpoint + 'vobjects/' + objectName;
    Http http = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndPoint(endpoint);
    req.setMethod('PUT');
    req.setHeader('Authorization', sessionId);
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Accept', 'application/json');
    req.setBody('[' + body + ']');
    HttpResponse res = http.send(req);
    return res;
  }

  public static String createPersonJSON(Contact contact, Boolean sfInactive) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    jsonGen.writeStringField('first_name__sys', contact.FirstName);
    jsonGen.writeStringField('last_name__sys', contact.LastName);
    if (contact.Email != null) {
      jsonGen.writeStringField('email__sys', contact.Email);
    }
    if (contact.MobilePhone != null) {
      jsonGen.writeStringField('mobile_phone__sys', contact.MobilePhone);
    }
    if (contact.Title != null) {
      jsonGen.writeStringField('title__c', contact.Title);
    }
    // if (contact.Person_Type__c != null) {
    //   jsonGen.writeStringField('object_type__v', contact.Person_Type__c);
    // }
    // Update Veeva Person
    if (contact.Veeva_ID__c != null) {
      jsonGen.writeStringField('id', contact.Veeva_ID__c);
    } else {
      jsonGen.writeStringField('external_id__v', contact.Id);
    }
    // Set inactive flag on Veeva Person
    if (sfInactive) {
      jsonGen.writeBooleanField('sf_inactive__c', sfInactive);
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  public static String createContactJSON(Contact_Junction__c contactJunction, String veevaPersonSysId) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    if (contactJunction.Contact__r.npe01__WorkPhone__c != null) {
      jsonGen.writeStringField('phone_number__clin', contactJunction.Contact__r.npe01__WorkPhone__c);
    }
    if (contactJunction.Contact__r.Fax != null) {
      jsonGen.writeStringField('fax_number__clin', contactJunction.Contact__r.Fax);
    }
    if (contactJunction.Clinical_Trial_Unit__r.Veeva_ID__C != null) {
      jsonGen.writeStringField('organization__clin', contactJunction.Clinical_Trial_Unit__r.Veeva_ID__C);
    } else if (contactJunction.Data_Hub_Contributor__r.Veeva_ID__C != null) {
      jsonGen.writeStringField('organization__clin', contactJunction.Data_Hub_Contributor__r.Veeva_ID__C);
    }
    if (contactJunction.Contact__r.Veeva_Contact_ID__c != null) {
      jsonGen.writeStringField('id', contactJunction.Contact__r.Veeva_Contact_ID__c);
    }
    if (!String.isBlank(veevaPersonSysId)) {
      if (contactJunction.Contact_Information_Type__c != null) {
        jsonGen.writeStringField('contact_information_type__clin', contactJunction.Contact_Information_Type__c);
      }
      jsonGen.writeStringField('external_id__v', contactJunction.Contact__c);
      jsonGen.writeStringField('person__clin', veevaPersonSysId);
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  public static String createPersonLocationJSON(ID contactJunctionId, String veevaPersonSysId, String veevaLocationId) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    jsonGen.writeStringField('external_id__v', contactJunctionId);
    jsonGen.writeStringField('person__clin', veevaPersonSysId);
    if (veevaLocationId != null) {
      jsonGen.writeStringField('location__clin', veevaLocationId);
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  public static String createCTNOrgJSON(Clinical_Trial_Unit__c organization) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    // Is create
    if (organization.Veeva_ID__c == null) {
      jsonGen.writeStringField('external_id__v', organization.Id);
    } else {
      jsonGen.writeStringField('id', organization.Veeva_ID__c);
    }
    jsonGen.writeStringField('name__v', organization.Name);
    if (organization.Affiliated_CTU__c != null && !String.IsBlank(organization.Affiliated_CTU__r.Veeva_ID__c)) {
      jsonGen.writeStringField('organization__clin', organization.Affiliated_CTU__r.Veeva_ID__c);
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  public static String createDHOrgJSON(Data_Hub_Contributor__c organization) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    // Is create
    if (organization.Veeva_ID__c == null) {
      jsonGen.writeStringField('external_id__v', organization.Id);
    } else {
      jsonGen.writeStringField('id', organization.Veeva_ID__c);
    }
    jsonGen.writeStringField('name__v', organization.Name);
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  public static String createLocationJSON(Address__c address) {
    System.debug('address' + address);
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    // Is create
    if (address.Veeva_ID__c == null) {
      jsonGen.writeStringField('external_id__v', address.Id);
    } else {
      jsonGen.writeStringField('id', address.Veeva_ID__c);
    }
    if (address.CTN__r.Name != null) {
      jsonGen.writeStringField('name__v', address.CTN__r.Name);
    } else if (address.Data_Hub__r.Name != null) {
      jsonGen.writeStringField('name__v', address.Data_Hub__r.Name);
    }
    jsonGen.writeStringField('address_line_1__clin', address.Street__c);
    if (address.Street2__c != null) {
      jsonGen.writeStringField('address_line_2__clin', address.Street2__c);
    }
    if (address.City__c != null) {
      jsonGen.writeStringField('town_city__clin', address.City__c);
    }
    if (address.State__c != null) {
      jsonGen.writeStringField('state_province_region__clin', address.State__c);
    }
    if (address.PostalCode__c != null) {
      jsonGen.writeStringField('postal_zip_code__clin', address.PostalCode__c);
    }
    if (address.Mailing_Country_Code__c != null) {
      jsonGen.writeStringField('country__v', address.Mailing_Country_Code__c);
    }
    if (address.CTN__r.Veeva_ID__c != null) {
      jsonGen.writeStringField('organization__clin', address.CTN__r.Veeva_ID__c);
    } else if (address.Data_Hub__r.Veeva_ID__c != null) {
      jsonGen.writeStringField('organization__clin', address.Data_Hub__r.Veeva_ID__c);
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  /**
   * Method to create person_location__clin object in Veeva Vault
   */
  @future(callout=true)
  public static void createVeevaPersonLocationRecord(ID contactJunctionId) {
    /* Query SF contact junction object */
    Contact_Junction__c contactJunction = [
      SELECT Id, Address__r.Veeva_ID__C, Contact__c, Contact__r.Veeva_ID__c
      FROM Contact_Junction__c WHERE Id =: contactJunctionId
    ];
    
    /* API Call */
    String apiEndpoint = 'https://ashrc-etmf.veevavault.com/api/v20.1/';
    /* Authenticate */
    HttpResponse authRes = authenticateVeeva(apiEndpoint);

    if (!authRes.getStatus().equals('OK')) {
      System.debug('The status code returned was not expected: ' + authRes.getStatusCode() + ' ' + authRes.getStatus());
    } else {
      Map<String,Object> authResBody = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
      System.debug(authResBody.get('sessionId'));

      String sessionId = authResBody.get('sessionId').toString();

      /* Create Person Location */
      System.debug('veevaPersonSysId ' + contactJunction.Contact__r.Veeva_ID__c);
      String createPersonLocationReqBody = createPersonLocationJSON(
        contactJunctionId,
        contactJunction.Contact__r.Veeva_ID__c,
        contactJunction.Address__r.Veeva_ID__C
      );
      System.debug('createPersonLocationReqBody: ' + createPersonLocationReqBody);
      HttpResponse createPersonLocationRes = createVeevaObject(apiEndpoint, sessionId, 'person_location__clin', createPersonLocationReqBody);

      if (!createPersonLocationRes.getStatus().equals('OK')) {
        System.debug('The status code returned was not expected: ' + createPersonLocationRes.getStatusCode() + ' ' + createPersonLocationRes.getStatus());
      } else {
        System.debug(createPersonLocationRes.getBody());
        VeevaSuccessResponse createPersonLocationResBody = VeevaSuccessResponse.parse(createPersonLocationRes.getBody());
        if (createPersonLocationResBody.data.get(0).responseStatus.equals('FAILURE')) {
          System.debug('Response status: ' + createPersonLocationResBody.data.get(0).responseStatus + ' ' + createPersonLocationResBody.data.get(0).errors.toString());
          return;
        }
        String personLocationId = createPersonLocationResBody.data.get(0).data.id;
        System.debug('personLocationId ' + personLocationId);

        /* Update SF Contact Junction with Veeva Person Location Id */
        contactJunction.Veeva_ID__c = personLocationId;
        update contactJunction;
        Contact_Junction__c contactJunctionUpdated = [SELECT Id, Veeva_ID__c FROM Contact_Junction__c WHERE Id =: contactJunctionId];
        System.debug('Veeva Person Location Id Added ' + contactJunctionUpdated);
      }
    }
  }

  /**
   * Method to create contact_information__clin object in Veeva Vault
   */
  @future(callout=true)
  public static void createVeevaContactRecord(ID contactJunctionId, ID contactId) {
    /* Query SF contact junction object */
    Contact_Junction__c contactJunction = [
      SELECT Id, Contact__r.npe01__WorkPhone__c, Contact__r.Fax, Contact__r.Veeva_Contact_ID__c, Contact__c, Active__c, Address__c,
      Address__r.Veeva_ID__C, Clinical_Trial_Unit__r.Veeva_ID__C, Data_Hub_Contributor__r.Veeva_ID__c, Contact_Information_Type__c
      FROM Contact_Junction__c WHERE Id =: contactJunctionId
    ];

    /* Query SF contact object */
    Contact contact = [
      SELECT Id, Email, FirstName, LastName, MobilePhone, Person_Type__c, Title, Veeva_ID__C
      FROM Contact WHERE Id =: contactId
    ];

    /* API Calls */
    String apiEndpoint = 'https://ashrc-etmf.veevavault.com/api/v20.1/';

    /* Authenticate */
    HttpResponse authRes = authenticateVeeva(apiEndpoint);

    if (!authRes.getStatus().equals('OK')) {
      System.debug('The status code returned was not expected: ' + authRes.getStatusCode() + ' ' + authRes.getStatus());
    } else {
      Map<String,Object> authResBody = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());

      String sessionId = authResBody.get('sessionId').toString();

      /* Create Objects in Veeva */

      /* Create Person */
      String createPersonReqBody = createPersonJSON(contact, false);
      HttpResponse createPersonRes = createVeevaObject(apiEndpoint, sessionId, 'person__sys', createPersonReqBody);

      // Handle create Person response
      if (!createPersonRes.getStatus().equals('OK')) {
        System.debug('The status code returned was not expected: ' + createPersonRes.getStatusCode() + ' ' + createPersonRes.getStatus());
      } else {
        VeevaSuccessResponse createPersonResBody = VeevaSuccessResponse.parse(createPersonRes.getBody());
        if (createPersonResBody.data.get(0).responseStatus.equals('FAILURE')) {
          System.debug('Response status: ' + createPersonResBody.data.get(0).responseStatus + ' ' + createPersonResBody.data.get(0).errors.toString());
          return;
        }
        String veevaPersonSysId = createPersonResBody.data.get(0).data.id;

        /* Create Contact passing person__sys id */
        String createContactReqBody = createContactJSON(contactJunction, veevaPersonSysId);

        HttpResponse createContactRes = createVeevaObject(apiEndpoint, sessionId, 'contact_information__clin', createContactReqBody);
  
        if (!createContactRes.getStatus().equals('OK')) {
          /* Update SF Contact with Veeva Ids */
          contact.Veeva_ID__c = veevaPersonSysId;
          update contact;
          System.debug('The status code returned was not expected: ' + createContactRes.getStatusCode() + ' ' + createContactRes.getStatus());
          return;
        } else {
          VeevaSuccessResponse createContactResBody = VeevaSuccessResponse.parse(createContactRes.getBody());
          if (createContactResBody.data.get(0).responseStatus.equals('FAILURE')) {
            System.debug('Response status: ' + createContactResBody.data.get(0).responseStatus + ' ' + createContactResBody.data.get(0).errors.toString());
            return;
          }
          String veevaContactId = createContactResBody.data.get(0).data.id;

          if (contactJunction.Address__c != null) {
            /* Create Person Location */
            System.debug('create contact veevaPersonSysId ' + veevaPersonSysId);
            String createPersonLocationReqBody = createPersonLocationJSON(contactJunctionId, veevaPersonSysId, contactJunction.Address__r.Veeva_ID__C);
            HttpResponse createPersonLocationRes = createVeevaObject(apiEndpoint, sessionId, 'person_location__clin', createPersonLocationReqBody);
  
            if (!createPersonLocationRes.getStatus().equals('OK')) {
              /* Update SF Contact with Veeva Ids */
              contact.Veeva_ID__c = veevaPersonSysId;
              contact.Veeva_Contact_ID__c = veevaContactId;
              update contact;
              System.debug('The status code returned was not expected: ' + createPersonLocationRes.getStatusCode() + ' ' + createPersonLocationRes.getStatus());
              return;
            } else {
              VeevaSuccessResponse createPersonLocationResBody = VeevaSuccessResponse.parse(createPersonLocationRes.getBody());
              if (createPersonLocationResBody.data.get(0).responseStatus.equals('FAILURE')) {
                /* Update SF Contact with Veeva Ids */
                contact.Veeva_ID__c = veevaPersonSysId;
                contact.Veeva_Contact_ID__c = veevaContactId;
                update contact;
                System.debug('Response status: ' + createPersonLocationResBody.data.get(0).responseStatus + ' ' + createPersonLocationResBody.data.get(0).errors.toString());
                return;
              }
              String personLocationId = createPersonLocationResBody.data.get(0).data.id;
  
              /* Update SF Contact with Veeva Ids */
              contact.Veeva_ID__c = veevaPersonSysId;
              contact.Veeva_Contact_ID__c = veevaContactId;
              update contact;
              Contact contactUpdated = [SELECT Id, Veeva_ID__c, Veeva_Contact_ID__c FROM Contact WHERE Id =: contactId];
              System.debug('Veeva Contact Id Added ' + contactUpdated);
  
              /* Update SF Contact Junction with Veeva Person Location Id */
              contactJunction.Veeva_ID__c = personLocationId;
              update contactJunction;
              Contact_Junction__c contactJunctionUpdated = [SELECT Id, Veeva_ID__c FROM Contact_Junction__c WHERE Id =: contactJunctionId];
              System.debug('Veeva Person Location Id Added ' + contactJunctionUpdated);
            }
          } else {
            /* Update SF Contact with Veeva Ids */
            contact.Veeva_ID__c = veevaPersonSysId;
            contact.Veeva_Contact_ID__c = veevaContactId;
            update contact;
            Contact contactUpdated = [SELECT Id, Veeva_ID__c, Veeva_Contact_ID__c FROM Contact WHERE Id =: contactId];
            System.debug('Veeva Contact Id Added ' + contactUpdated);
          }
        }
      }
    }
  }

  /**
   * Method to update contact_information__clin object in Veeva Vault
   */
  @future(callout=true)
  public static void updateVeevaPersonRecord(ID contactId) {
    System.debug('updateVeevaPersonRecord');
    /* Query SF contact object */
    Contact contact = [
      SELECT Id, Email, FirstName, LastName, MobilePhone, Person_Type__c, Title, Veeva_ID__C FROM Contact WHERE Id =: contactId
    ];

    /* Query SF contact junction object */
    List<Contact_Junction__c> contactJunctions = [SELECT Id,Contact__c FROM Contact_Junction__c WHERE Contact__c =: contactId];

    /* API Calls */
    String apiEndpoint = 'https://ashrc-etmf.veevavault.com/api/v20.1/';

    /* Authenticate */
    HttpResponse authRes = authenticateVeeva(apiEndpoint);

    if (!authRes.getStatus().equals('OK')) {
      System.debug('The status code returned was not expected: ' + authRes.getStatusCode() + ' ' + authRes.getStatus());
    } else {
      Map<String,Object> authResBody = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
      System.debug(authResBody.get('sessionId'));

      String sessionId = authResBody.get('sessionId').toString();

      // Update SF Inactive, If no Contact Junctions on Contact, set sfInactive
      Boolean sfInactive = false;
      if (contactJunctions.size() == 0) {
        sfInactive = true;
      }
      /* Update Person */
      String updatePersonReqBody = createPersonJSON(contact, sfInactive);
      System.debug('updatePersonReqBody: ' + updatePersonReqBody);
      HttpResponse updatePersonRes = updateVeevaObject(apiEndpoint, sessionId, 'person__sys', updatePersonReqBody);

      if (!updatePersonRes.getStatus().equals('OK')) {
        System.debug('The status code returned was not expected: ' + updatePersonRes.getStatusCode() + ' ' + updatePersonRes.getStatus());
      } else {
        System.debug(updatePersonRes.getBody());
        VeevaSuccessResponse updatePersonResBody = VeevaSuccessResponse.parse(updatePersonRes.getBody());
        System.debug('updatePersonResBody ' + updatePersonResBody);
      }
    }
  }

  /**
   * Method to update contact_information__clin object in Veeva Vault
   */
  @future(callout=true)
  public static void updateVeevaContactRecord(ID contactId) {
    System.debug('updateVeevaContactRecord');
    /* Query SF contact junction object */
    Contact_Junction__c contactJunction = [
      SELECT Id, Contact__r.npe01__WorkPhone__c, Contact__r.Fax, Contact__r.Veeva_Contact_ID__c, Contact__c,
      Clinical_Trial_Unit__r.Veeva_ID__C, Data_Hub_Contributor__r.Veeva_ID__c, Contact_Information_Type__c
      FROM Contact_Junction__c WHERE Contact__c =: contactId
    ];

    /* API Calls */
    String apiEndpoint = 'https://ashrc-etmf.veevavault.com/api/v20.1/';

    /* Authenticate */
    HttpResponse authRes = authenticateVeeva(apiEndpoint);

    if (!authRes.getStatus().equals('OK')) {
      System.debug('The status code returned was not expected: ' + authRes.getStatusCode() + ' ' + authRes.getStatus());
    } else {
      Map<String,Object> authResBody = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
      System.debug(authResBody.get('sessionId'));

      String sessionId = authResBody.get('sessionId').toString();

      /* Update Contact */
      String updateContactReqBody = createContactJSON(contactJunction, '');

      HttpResponse updateContactRes = updateVeevaObject(apiEndpoint, sessionId, 'contact_information__clin', updateContactReqBody);

      if (!updateContactRes.getStatus().equals('OK')) {
        System.debug('The status code returned was not expected: ' + updateContactRes.getStatusCode() + ' ' + updateContactRes.getStatus());
      } else {
        System.debug(updateContactRes.getBody());
        VeevaSuccessResponse updateContactResBody = VeevaSuccessResponse.parse(updateContactRes.getBody());
        System.debug('updateContactResBody ' + updateContactResBody);
      }
    }
  }

  /**
   * Method to create organization__v object in Veeva Vault
   */
  @future(callout=true)
  public static void createVeevaOrganizationRecord(ID organizationId, String locationType) {
    /* API Calls */
    String apiEndpoint = 'https://ashrc-etmf.veevavault.com/api/v20.1/';

    /* Authenticate */
    HttpResponse authRes = authenticateVeeva(apiEndpoint);

    if (!authRes.getStatus().equals('OK')) {
      System.debug('The status code returned was not expected: ' + authRes.getStatusCode() + ' ' + authRes.getStatus());
    } else {
      Map<String,Object> authResBody = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
      System.debug(authResBody.get('sessionId'));

      String sessionId = authResBody.get('sessionId').toString();

      /* Create Objects in Veeva */

      /* Create Organization */
      String createOrgReqBody = '';

      if (locationType.equals('ctn')) {
        Clinical_Trial_Unit__c ctu = [
          SELECT Id, Name, Affiliated_CTU__c, Affiliated_CTU__r.Veeva_ID__C, Veeva_ID__c
          FROM Clinical_Trial_Unit__c WHERE Id =: organizationId
        ];
        createOrgReqBody = createCTNOrgJSON(ctu);
      } else {
        Data_Hub_Contributor__c dh = [
          SELECT Id, Name, Veeva_ID__c, Institution__r.Name
          FROM Data_Hub_Contributor__c WHERE Id =: organizationId
        ];
        createOrgReqBody = createDHOrgJSON(dh);
      }
      System.debug('createOrgReqBody: ' + createOrgReqBody);

      HttpResponse createOrgRes = createVeevaObject(apiEndpoint, sessionId, 'organization__v', createOrgReqBody);

      if (!createOrgRes.getStatus().equals('OK')) {
        System.debug('The status code returned was not expected: ' + createOrgRes.getStatusCode() + ' ' + createOrgRes.getStatus());
      } else {
        System.debug(createOrgRes.getBody());
        VeevaSuccessResponse createOrgResBody = VeevaSuccessResponse.parse(createOrgRes.getBody());
        System.debug('createOrgResBody ' + createOrgResBody);
        // Failed Response, no data
        if (createOrgResBody.data.get(0).responseStatus.equals('FAILURE')) {
          System.debug('Response status: ' + createOrgResBody.data.get(0).responseStatus + ' ' + createOrgResBody.data.get(0).errors.toString());
          return;
        }
        System.debug('createOrgResBody ' + createOrgResBody);
        String veevaId = createOrgResBody.data.get(0).data.id;
        System.debug('veevaId ' + veevaId);

        /* Update SF with Veeva Id */
        if (locationType.equals('ctn')) {
          /* Query SF Clinical_Trial_Unit__c object */
          Clinical_Trial_Unit__c ctu = [SELECT Id FROM Clinical_Trial_Unit__c WHERE Id =: organizationId];
          ctu.Veeva_ID__c = veevaId;
          update ctu;
          Clinical_Trial_Unit__c ctuUpdated = [SELECT Id, Veeva_ID__c FROM Clinical_Trial_Unit__c WHERE Id =: organizationId];
          System.debug('Veeva Organization Id Added ' + ctuUpdated);
        } else {
          Data_Hub_Contributor__c dh = [SELECT Id FROM Data_Hub_Contributor__c WHERE Id =: organizationId];
          dh.Veeva_ID__c = veevaId;
          update dh;
          Data_Hub_Contributor__c dhUpdated = [SELECT Id, Veeva_ID__c FROM Data_Hub_Contributor__c WHERE Id =: organizationId];
          System.debug('Veeva Organization Id Added ' + dhUpdated);
        }
      }
    }
  }

  /**
   * Method to update organization__v object in Veeva Vault
   */
  @future(callout=true)
  public static void updateVeevaOrganizationRecord(ID organizationId, String locationType) {
    /* API Calls */
    String apiEndpoint = 'https://ashrc-etmf.veevavault.com/api/v20.1/';

    /* Authenticate */
    HttpResponse authRes = authenticateVeeva(apiEndpoint);

    if (!authRes.getStatus().equals('OK')) {
      System.debug('The status code returned was not expected: ' + authRes.getStatusCode() + ' ' + authRes.getStatus());
    } else {
      Map<String,Object> authResBody = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
      System.debug(authResBody.get('sessionId'));

      String sessionId = authResBody.get('sessionId').toString();

      /* Update Organization */
      String updateAccountReqBody = '';
      if (locationType.equals('ctn')) {
        Clinical_Trial_Unit__c ctu = [
          SELECT Id, Name, Affiliated_CTU__c, Affiliated_CTU__r.Veeva_ID__C, Veeva_ID__c
          FROM Clinical_Trial_Unit__c WHERE Id =: organizationId
        ];
        updateAccountReqBody = createCTNOrgJSON(ctu);
      } else {
        Data_Hub_Contributor__c dh = [
          SELECT Id, Name, Veeva_ID__c
          FROM Data_Hub_Contributor__c WHERE Id =: organizationId
        ];
        updateAccountReqBody = createDHOrgJSON(dh);
      }

      HttpResponse updateAccountRes = updateVeevaObject(apiEndpoint, sessionId, 'organization__v', updateAccountReqBody);

      if (!updateAccountRes.getStatus().equals('OK')) {
        System.debug('The status code returned was not expected: ' + updateAccountRes.getStatusCode() + ' ' + updateAccountRes.getStatus());
      } else {
        System.debug(updateAccountRes.getBody());
        VeevaSuccessResponse updateAccountResBody = VeevaSuccessResponse.parse(updateAccountRes.getBody());
        System.debug('updateAccountResBody ' + updateAccountResBody);
      }
    }
  }

  /**
   * Method to create location__v object in Veeva Vault
   */
  @future(callout=true)
  public static void createVeevaLocationRecord(ID addressId) {
    
    /* API Call */
    String apiEndpoint = 'https://ashrc-etmf.veevavault.com/api/v20.1/';
    /* Authenticate */
    HttpResponse authRes = authenticateVeeva(apiEndpoint);

    if (!authRes.getStatus().equals('OK')) {
      System.debug('The status code returned was not expected: ' + authRes.getStatusCode() + ' ' + authRes.getStatus());
    } else {
      Map<String,Object> authResBody = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
      System.debug(authResBody.get('sessionId'));

      String sessionId = authResBody.get('sessionId').toString();

      /* Create Location */
      Address__c address = [
        SELECT Id, Street__c, Street2__c, City__c, State__c, PostalCode__c,
        Mailing_Country_Code__c, CTN__r.Veeva_ID__c, CTN__r.Name, Data_Hub__r.Name, Data_Hub__r.Veeva_ID__c, Veeva_ID__c
        FROM Address__c WHERE Id =: addressId
      ];
      System.debug('create' + address);
      String reqBody = createLocationJSON(address);
      HttpResponse res = createVeevaObject(apiEndpoint, sessionId, 'location__v', reqBody);

      if (!res.getStatus().equals('OK')) {
        System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
      } else {
        System.debug(res.getBody());
        VeevaSuccessResponse resBody = VeevaSuccessResponse.parse(res.getBody());
        if (resBody.data.get(0).responseStatus.equals('FAILURE')) {
          System.debug('Response status: ' + resBody.data.get(0).responseStatus + ' ' + resBody.data.get(0).errors.toString());
          return;
        }
        String locationId = resBody.data.get(0).data.id;
        System.debug('locationId ' + locationId);

        /* Update SF Address with Veeva Location Id */
        address.Veeva_ID__c = locationId;
        update address;
        Address__c addressUpdated = [SELECT Id, Veeva_ID__c FROM Address__c WHERE Id =: addressId];
        System.debug('Veeva Location Id Added ' + addressUpdated);
      }
    }
  }

  /**
   * Method to create location__v object in Veeva Vault
   */
  @future(callout=true)
  public static void updateVeevaLocationRecord(ID addressId) {
    
    /* API Call */
    String apiEndpoint = 'https://ashrc-etmf.veevavault.com/api/v20.1/';
    /* Authenticate */
    HttpResponse authRes = authenticateVeeva(apiEndpoint);

    if (!authRes.getStatus().equals('OK')) {
      System.debug('The status code returned was not expected: ' + authRes.getStatusCode() + ' ' + authRes.getStatus());
    } else {
      Map<String,Object> authResBody = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
      System.debug(authResBody.get('sessionId'));

      String sessionId = authResBody.get('sessionId').toString();

      /* Update Location */
      Address__c address = [
        SELECT Id, Street__c, Street2__c, City__c, State__c, PostalCode__c,
        Mailing_Country_Code__c, CTN__r.Veeva_ID__c, CTN__r.Name, Data_Hub__r.Name, Data_Hub__r.Veeva_ID__c, Veeva_ID__c
        FROM Address__c WHERE Id =: addressId
      ];
      System.debug('update' + address);
      String reqBody = createLocationJSON(address);
      HttpResponse res = updateVeevaObject(apiEndpoint, sessionId, 'location__v', reqBody);

      if (!res.getStatus().equals('OK')) {
        System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
      } else {
        System.debug(res.getBody());
        VeevaSuccessResponse resBody = VeevaSuccessResponse.parse(res.getBody());
        if (resBody.data.get(0).responseStatus.equals('FAILURE')) {
          System.debug('Response status: ' + resBody.data.get(0).responseStatus + ' ' + resBody.data.get(0).errors.toString());
          return;
        }
      }
    }
  }
}