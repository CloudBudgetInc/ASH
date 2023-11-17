public class VendorCodeHandler {

    public static String generateVendorCode(Account account, Map<Id, Account> vendors, 
                                            Map<Id, Legacy_Vendor__c> legacyVendors) {
        
	    Map<String, Account> vendorLookup = new Map<String, Account>();
    	for( String key : vendors.keySet() ) {
        	Account someVendor = vendors.get(key);
        	vendorLookup.put(someVendor.Vendor_ID__c, someVendor);
    	}
                                                
	    Map<String, Legacy_Vendor__c> legacyVendorLookup = new Map<String, Legacy_Vendor__c>();
    	for( String key : legacyVendors.keySet() ) {
        	Legacy_Vendor__c someLegacyVendor = legacyVendors.get(key);
        	legacyVendorLookup.put(someLegacyVendor.Vendor_ID__c, someLegacyVendor);
    	}                                                   
                                                    
		// loop to 999 until we find an unoccupied vendor ID using the key value provided.
		String vendorKey = account.Vendor_Key__c.toUpperCase();
       	for(Integer i = 1 ; i < 999; i++ ) {
        	String vendorId;
          	if( i < 10 ) {
       		   	vendorId = vendorKey.left(4) + '0' + i;
            }
            else {
               	vendorId = vendorKey.left(4) + i;
            }
            if(!vendorLookup.containsKey(vendorId) && !legacyVendorLookup.containsKey(vendorId))
            { 
                String vendorIdToUpper = vendorId.toUpperCase();
            	return vendorIdToUpper;
            }
       	} 
		return '';
    }
}