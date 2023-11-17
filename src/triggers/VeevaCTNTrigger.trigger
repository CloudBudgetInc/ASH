trigger VeevaCTNTrigger on Clinical_Trial_Unit__c (after insert, after update) {
  if (Trigger.isInsert) {
    // Insert
    for (Clinical_Trial_Unit__c ctu : Trigger.new) {
      System.debug('new ctu ' + ctu.Name + ' ' + ctu.Id);
      // Create Organization in Veeva and update ctu.Veeva_ID__c in SF
      VeevaCalloutClass.createVeevaOrganizationRecord(ctu.Id, 'ctn');
    }
  } else if (Trigger.isUpdate) {
    // Update
    for (Clinical_Trial_Unit__c ctu : Trigger.new) {
      System.debug('update ctu ' + ctu.Name + ' ' + ctu.Id);
      if (!System.isFuture() && !System.isBatch()) {
        // Update Organization in Veeva
        VeevaCalloutClass.updateVeevaOrganizationRecord(ctu.Id, 'ctn');
      }
    }
  }
}