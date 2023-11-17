public class ComboRuleProvider {
    
    private static ComboRuleProvider instance = null;
    public String id { get; private set; } // the id of the record type    
    
	List<c2g__CombinationRuleLineItem__c> comboRules = new List<c2g__CombinationRuleLineItem__c>();
    
    public static ComboRuleProvider getInstance() {
        if( instance == null ) instance = new ComboRuleProvider();
        return instance;
    }    
    
    // The constructor is private.
    private ComboRuleProvider() { 

        comboRules = 
            [SELECT c2g__CombinationRule__r.c2g__Company__r.Key__c,
             c2g__CombinationRule__r.c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c, 
             c2g__CombinationRule__r.c2g__EffectiveDateFrom__c, c2g__CombinationRule__r.c2g__EffectiveDateTo__c,
             c2g__Dimension1Value__r.c2g__ReportingCode__c, c2g__Dimension2Value__r.c2g__ReportingCode__c, 
             c2g__Dimension3Value__r.c2g__ReportingCode__c, c2g__Dimension4Value__r.c2g__ReportingCode__c 
             FROM c2g__CombinationRuleLineItem__c];        
    }
    
    public boolean validate(String companyKey, String glCode, String dim1, String dim2, String dim3, String dim4) {
        
        System.debug('Validating ' + companyKey + ', ' + glCode + ', ' + dim1 + ', '+ dim2 + ', '+ dim3 + ', ' + dim4);
        
        for(c2g__CombinationRuleLineItem__c someCrli : comboRules) {
            if( someCrli.c2g__CombinationRule__r.c2g__Company__r.Key__c == companyKey &&
              someCrli.c2g__CombinationRule__r.c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c == glCode && 
              someCrli.c2g__Dimension1Value__r.c2g__ReportingCode__c == dim1 && 
              someCrli.c2g__Dimension2Value__r.c2g__ReportingCode__c == dim2 && 
              someCrli.c2g__Dimension3Value__r.c2g__ReportingCode__c == dim3 && 
              someCrli.c2g__Dimension4Value__r.c2g__ReportingCode__c == dim4 &&
              someCrli.c2g__CombinationRule__r.c2g__EffectiveDateFrom__c <= System.today() && 
              (someCrli.c2g__CombinationRule__r.c2g__EffectiveDateTo__c == null || 
               someCrli.c2g__CombinationRule__r.c2g__EffectiveDateTo__c >= System.today()))
			  {
                  return true;
              }
        }
        System.debug('Matching account string not found. Returning false.');
        return false;
    }
    
    public boolean validate(Id companyId, String glId, String dim1Id, String dim2Id, String dim3Id, String dim4Id) {
        
        System.debug('Validating ' + companyId + ', ' + glId + ', ' + dim1Id + ', '+ dim2Id + ', '+ dim3Id + ', ' + dim4Id);
        
        for(c2g__CombinationRuleLineItem__c someCrli : comboRules) {
            if( someCrli.c2g__CombinationRule__r.c2g__Company__c == companyId &&
              someCrli.c2g__CombinationRule__r.c2g__GeneralLedgerAccount__c == glId && 
              someCrli.c2g__Dimension1Value__c == dim1Id && 
              someCrli.c2g__Dimension2Value__c == dim2Id && 
              someCrli.c2g__Dimension3Value__c == dim3Id && 
              someCrli.c2g__Dimension4Value__c == dim4Id &&
              someCrli.c2g__CombinationRule__r.c2g__EffectiveDateFrom__c <= System.today() && 
              (someCrli.c2g__CombinationRule__r.c2g__EffectiveDateTo__c == null || 
               someCrli.c2g__CombinationRule__r.c2g__EffectiveDateTo__c >= System.today()))
			  {
                  return true;
              }
        }
        System.debug('Matching account string not found. Returning false.');
        return false;
    }    
}