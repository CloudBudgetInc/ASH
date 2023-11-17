trigger VeevaAddressTrigger on Address__c (after insert, after update) {
  if (Trigger.isInsert) {
    // Insert
    for (Address__c address : Trigger.new) {
      System.debug('new address ' + address.Name + ' ' + address.Id);
      if (address.CTN__c != null || address.Data_Hub__c != null) {
        // Create Location in Veeva and update address.Veeva_ID__c in SF
        VeevaCalloutClass.createVeevaLocationRecord(address.Id);
      }
    }
  } else if (Trigger.isUpdate) {
    // Update
    for (Address__c address : Trigger.new) {
      System.debug('update address ' + address.Name + ' ' + address.Id);
      if (!System.isFuture() && !System.isBatch()) {
        if (address.CTN__c != null || address.Data_Hub__c != null) {
          // Update Location in Veeva
          VeevaCalloutClass.updateVeevaLocationRecord(address.Id);
        }
      }
    }
  }
}