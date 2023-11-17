trigger VeevaDataHubTrigger on Data_Hub_Contributor__c (after insert, after update) {
  if (Trigger.isInsert) {
    // Insert
    for (Data_Hub_Contributor__c dh : Trigger.new) {
      System.debug('new dh ' + dh.Name + ' ' + dh.Id);
      // Create Organization in Veeva and update dh.Veeva_ID__c in SF
      VeevaCalloutClass.createVeevaOrganizationRecord(dh.Id, 'dh');
    }
  } else if (Trigger.isUpdate) {
    // Update
    for (Data_Hub_Contributor__c dh : Trigger.new) {
      System.debug('update dh ' + dh.Name + ' ' + dh.Id);
      if (!System.isFuture() && !System.isBatch()) {
        // Update Organization in Veeva
        VeevaCalloutClass.updateVeevaOrganizationRecord(dh.Id, 'dh');
      }
    }
  }
}