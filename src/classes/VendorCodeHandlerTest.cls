@isTest(SeeAllData=true)
public class VendorCodeHandlerTest {
    
   	static testMethod void testGetVendorCode() {

		Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
		Account someAccount = new Account();
        someAccount.Name = 'ZYZA Consulting';
        someAccount.Vendor_Key__c = 'ZYZA';
        someAccount.RecordTypeId = vendorRecordTypeId;        
        insert someAccount; // insertions automatically get a vendor code, so this gets ZYZA01.
	    Map<Id, Account> vendors = new Map<Id, Account>([SELECT Id, Vendor_ID__c FROM Account WHERE RecordTypeId = :vendorRecordTypeId
                                                        AND CreatedDate > LAST_MONTH]);
        Map<Id, Legacy_Vendor__c> legacyVendors = new Map<Id, Legacy_Vendor__c>([SELECT Id, Vendor_ID__c FROM Legacy_Vendor__c]);         
        String someResult = VendorCodeHandler.generateVendorCode(someAccount, vendors, legacyVendors);
		// Verifies that ZYZA01 is now occupied by the insert, and a properly incremented 
		// vendor ID was generated.
        System.assertEquals('ZYZA02', someResult);
    }
    
   	static testMethod void testLegacyGetVendorCode() {

        Legacy_Vendor__c someLegacyVendor = new Legacy_Vendor__c();
        someLegacyVendor.Vendor_ID__c = 'ZZZY01';
        someLegacyVendor.Vendor_Name__c = 'Sleepy Cousins';
        insert someLegacyVendor;        
        
		Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
		Account someAccount = new Account();
        someAccount.Name = 'Sleepy Consulting';
        someAccount.Vendor_Key__c = 'ZZZY';
        someAccount.RecordTypeId = vendorRecordTypeId; 
        
	    Map<Id, Account> vendors = new Map<Id, Account>([SELECT Id, Vendor_ID__c FROM Account WHERE RecordTypeId = :vendorRecordTypeId]);
        Map<Id, Legacy_Vendor__c> legacyVendors = new Map<Id, Legacy_Vendor__c>([SELECT Id, Vendor_ID__c FROM Legacy_Vendor__c]);         
        String someResult = VendorCodeHandler.generateVendorCode(someAccount, vendors, legacyVendors);
        System.assertEquals('ZZZY02', someResult);
    }    
    
}