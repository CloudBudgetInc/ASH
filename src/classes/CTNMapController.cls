public with sharing class CTNMapController {
	@RemoteAction
	public static List<Account> getAccounts() {
		List<Account> accounts = [SELECT Id, Name, Description, ShippingAddress, ShippingGeocodeAccuracy, ShippingLatitude, ShippingLongitude
			FROM Account WHERE Id IN (SELECT Primary_Site__c FROM Clinical_Trial_Unit__c WHERE RecordType.Name = 'CTN Approved')
		];

		return accounts;
	}

	@RemoteAction
	public static List<Clinical_Trial_Unit__c> getCTUs() {
		List<Clinical_Trial_Unit__c> ctus = [SELECT Id, Name, Primary_Site__r.Id, Primary_Site__r.Name, Primary_Site__r.ShippingAddress, 
			Primary_Site__r.ShippingLatitude, Primary_Site__r.ShippingLongitude, Site_Coordinator__r.Name, Site_Coordinator__r.Phone
			FROM Clinical_Trial_Unit__c WHERE RecordType.Name = 'CTN Approved'
		];

		return ctus;
	}
}