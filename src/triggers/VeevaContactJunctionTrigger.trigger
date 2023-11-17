trigger VeevaContactJunctionTrigger on Contact_Junction__c (
  after insert,
  after update
) {
  if (Trigger.isInsert) {
    // Insert
    for (Contact_Junction__c contactJunction : Trigger.new) {
      Contact_Junction__c cj = [
      SELECT Id, Contact__r.Veeva_ID__c, Contact__r.ASH_RC_Engaged__c
      FROM Contact_Junction__c WHERE Id =: contactJunction.Id
    ];
      System.debug('new contactJunction' + contactJunction + contactJunction.Contact__c);
      System.debug(cj.Contact__r.Veeva_ID__c);
      // If related contact.Veeva_ID__c = null
      if (cj.Contact__r.Veeva_ID__c == null) {
        System.debug('create Person in Veeva');
        // Create Person in Veeva and update contact.Veeva_ID__c in SF
        // Create Contact in Veeva and update contact.Veeva_Contact_ID__c in SF
        // Create Person Location in Veeva and update contactJunction.Veeva_ID__c in SF
        if (VeevaTriggerCheckRecursive.runOnce()) {
          VeevaCalloutClass.createVeevaContactRecord(contactJunction.Id, contactJunction.Contact__c);
        }
      } else {
        System.debug('create Person location in Veeva');
        // Create Person Location in Veeva and update contactJunction.Veeva_ID__c in SF
        if (VeevaTriggerCheckRecursive.runOnce()) {
          VeevaCalloutClass.createVeevaPersonLocationRecord(contactJunction.Id);
        }
      }
    }
  } else if (Trigger.isUpdate) {
    for (Contact_Junction__c contactJunction : Trigger.new) {
      if (!System.isFuture() && !System.isBatch()) {
        System.debug('update Person and Contact in Veeva');
        // Update Person in Veeva
        VeevaCalloutClass.updateVeevaPersonRecord(contactJunction.Contact__c);
        // Update Contact in Veeva
        VeevaCalloutClass.updateVeevaContactRecord(contactJunction.Contact__c);
        System.debug('create Person location in Veeva');
        // Create Person Location in Veeva and update contactJunction.Veeva_ID__c in SF
        if (contactJunction.Address__r.Veeva_ID__C == null) {
          VeevaCalloutClass.createVeevaPersonLocationRecord(contactJunction.Id);
        }
      }
    }
  }
}