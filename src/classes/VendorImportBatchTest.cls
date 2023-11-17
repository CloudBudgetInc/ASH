@isTest(SeeAllData=true)
public class VendorImportBatchTest {
    
	static testMethod void testVendorImportBatch() {  
        
        Vendor_Import__c someVendorImport = new Vendor_Import__c( 
        	Remit_Name__c = 'ABC Plumbing',
            Invoice_Email__c = 'abc-test@hematology.org',
            Vendor_ID__c = 'ABCP01',
            Payment_Method__c = 'Check',
            Remit_Address_1__c = '123 Main Road',
            Remit_Address_2__c = 'Suite 1',
            Remit_City__c = 'Annapolis',
            Remit_State__c = 'MD',
            Remit_Postal_Code__c = '23405',
            Remit_Country_Code__c = 'US',
        	X1099_Vendor__c = 'true',
            Default_Box_Selection__c = '3',
            TIN_Name__c = 'ABC Plumbing',
            Tax_ID_Number__c = '930-30-3003',
            Bank_Account_Number__c = '9999999',
            Bank_Routing_Number__c = '2930292',
            SWIFT_Number__c = '2939022',
            IBAN_Number__c = '3920029',
            International_Subtype__c = 'IBAN',
            Wire_Bank_Name__c = 'Truist',
            Wire_Bank_Reference__c = 'Unknown',
            Wire_Bank_Street__c = '345 Plaza Deville',
            Wire_Bank_City__c = 'Milan',
            Wire_Bank_State__c = 'MI',
            Wire_Bank_Postal_Code__c = 'RAE930',
            Wire_Bank_Country__c = 'IT');
            
            insert someVendorImport;
        
            Test.startTest();
        	VendorImportBatch vib = new VendorImportBatch();
        	Id jobId = Database.executeBatch(vib, 1);
        	Test.stopTest();
    }

}