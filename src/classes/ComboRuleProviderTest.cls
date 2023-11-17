@isTest(SeeAllData=true)
public class ComboRuleProviderTest {
    
    static testMethod void mainTest() {
        
        Id companyId = [SELECT Id FROM c2g__codaCompany__c WHERE Key__c = 'ASH'].Id;
        Id glId = [SELECT Id FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = '7020'].Id;
        Id dim1Id = [SELECT Id FROM c2g__codaDimension1__c WHERE c2g__ReportingCode__c = '112'].Id;
        Id dim2Id = [SELECT Id FROM c2g__codaDimension2__c WHERE c2g__ReportingCode__c = '359'].Id;
        Id dim3Id = [SELECT Id FROM c2g__codaDimension3__c WHERE c2g__ReportingCode__c = '000'].Id;
        Id dim4Id = [SELECT Id FROM c2g__codaDimension4__c WHERE c2g__ReportingCode__c = '39'].Id;
        
        ComboRuleProvider provider = ComboRuleProvider.getInstance();
        boolean goodResult = provider.validate('ASH', '7020', '112', '359','000','00');
        System.assertEquals(true, goodResult);
        boolean badResult = provider.validate('ASH', '7020', '999', '359','000','00');
        System.assertEquals(false, badResult);
        boolean anotherBadResult = provider.validate(companyId, glId, dim1Id, dim2Id, dim3Id, dim4Id);
        System.assertEquals(false, anotherBadResult);
    }
        

}