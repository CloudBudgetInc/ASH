trigger VeevaContactTrigger on Contact (after update) {
  if (Trigger.isUpdate) {
     // Update
    for (Contact contact : Trigger.new) {
      System.debug('update contact: ' + contact.Id  + ' ' + contact.Veeva_ID__c  + ' ' + contact.ASH_RC_Engaged__c);
      if (contact.Veeva_ID__c != null) {
        if (VeevaTriggerCheckRecursive.runOnce()) {
          if (!System.isFuture() && !System.isBatch()) {
            System.debug('update Person and Contact in Veeva');
            // Update Person in Veeva
            VeevaCalloutClass.updateVeevaPersonRecord(contact.Id);
            // Update Contact in Veeva
            VeevaCalloutClass.updateVeevaContactRecord(contact.Id);
          }
        }
      }
    }
  }
}