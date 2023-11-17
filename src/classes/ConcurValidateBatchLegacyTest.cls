@isTest(SeeAllData=true)
public class ConcurValidateBatchLegacyTest {

    static testMethod void testConcurExpenseValidation() {
        
        Concur_Batch__c someBatch = new Concur_Batch__c(Processed__c = false, Type__c = 'Expense');
        insert someBatch;        
        
		Payment_Shuttle__c someShuttle = new Payment_Shuttle__c(Invoice_Number__c='BAAAP', Company_ID__c='ASH', Account_Code__c='7020', 
        	Department__c = '100', Program__c = '000', Project__c = '000', Other__c = '00', Vendor_ID__c = 'TRIS01', Type__c = 'Expense');
        someShuttle.Concur_Batch__c = someBatch.Id;
        insert someShuttle;
		Payment_Shuttle__c secondShuttle = new Payment_Shuttle__c(Invoice_Number__c='BAAAP',Company_ID__c='ASH', Account_Code__c='7020', 
        	Department__c = '112', Program__c = '359', Project__c = '000', Other__c = '00', Vendor_ID__c = 'TRIS01', Type__c = 'Expense');
        secondShuttle.Concur_Batch__c = someBatch.Id;
        insert secondShuttle;               
		Payment_Shuttle__c thirdShuttle = new Payment_Shuttle__c(Invoice_Number__c='BOOOP',Company_ID__c='ASH', Account_Code__c='7020', 
        	Department__c = '112', Program__c = '359', Project__c = '000', Other__c = '00', Type__c = 'Expense');
        thirdShuttle.Concur_Batch__c = someBatch.Id;
        insert thirdShuttle;        
        
        Test.startTest();
        ConcurValidateExpenseBatch cvb = new ConcurValidateExpenseBatch(someBatch.Id);
        Id jobid = Database.executeBatch(cvb, 5);
        Test.stopTest();
        
        Payment_Shuttle__c testResult = [SELECT Id, Failed__c, Reason__c FROM Payment_Shuttle__c WHERE Id = :someShuttle.Id];
        System.assertEquals(true, testResult.Failed__c);
        System.assertEquals('Invalid account code.', testResult.Reason__c);
        Payment_Shuttle__c testResult2 = [SELECT Id, Failed__c, Reason__c FROM Payment_Shuttle__c WHERE Id = :secondShuttle.Id];
        System.assertEquals(true, testResult2.Failed__c);
        System.assertEquals('Failed as accomplice.', testResult2.Reason__c);
        Payment_Shuttle__c testResult3 = [SELECT Id, Failed__c FROM Payment_Shuttle__c WHERE Id = :thirdShuttle.Id];
        System.assertEquals(false, testResult3.Failed__c);
    }

    static testMethod void testConcurInvoiceValidation() {
        
        Concur_Batch__c someBatch = new Concur_Batch__c(Processed__c = false, Type__c = 'Invoice');
        insert someBatch;            
        
		Payment_Shuttle__c someShuttle = new Payment_Shuttle__c(Invoice_Number__c='BAAAP', Company_ID__c='ASH', Account_Code__c='7020', 
        	Department__c = '100', Program__c = '000', Project__c = '000', Other__c = '00', Type__c = 'Invoice');
        someShuttle.Concur_Batch__c = someBatch.Id;        
        insert someShuttle;
		Payment_Shuttle__c anotherShuttle = new Payment_Shuttle__c(Invoice_Number__c='BOOOP',Company_ID__c='ASH', Account_Code__c='7020', 
        	Batch__c = '9999', Type__c = 'Invoice', Department__c = '112', Program__c = '359', Project__c = '000', Other__c = '00');
        anotherShuttle.Concur_Batch__c = someBatch.Id;
        insert anotherShuttle;        
        
        Test.startTest();
        ConcurValidateInvoiceBatch cvb = new ConcurValidateInvoiceBatch(someBatch.Id);
        Id jobid = Database.executeBatch(cvb, 5);
        Test.stopTest();
        
        Payment_Shuttle__c testResult = [SELECT Id, Failed__c, Reason__c FROM Payment_Shuttle__c WHERE Id = :someShuttle.Id];
        System.assertEquals(true, testResult.Failed__c);
        System.assertEquals('Invalid account code.', testResult.Reason__c);
        Payment_Shuttle__c testResult2 = [SELECT Id, Failed__c FROM Payment_Shuttle__c WHERE Id = :anotherShuttle.Id];
        System.assertEquals(false, testResult2.Failed__c);
    }
}