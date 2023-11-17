public class CodeErrorHandler {
    
    public static void handleDimensionErrors(Id user, String subaccount, c2g__codaDimension1__c someDim1, c2g__codaDimension2__c someDim2, 
                                 c2g__codaDimension3__c someDim3, c2g__codaDimension4__c someDim4) {                             
		String error = '';
                                     
        if(someDim1 == null ) {
            error += 'Department ' + subaccount.substring(0,3) + ' is invalid. ';
        }
        if(someDim2 == null ) {          
            error += 'Program ' + subaccount.substring(0,3) + ' is invalid. ';
        }
        if(someDim3 == null ) {          
            error += 'Project ' + subaccount.substring(0,3) + ' is invalid. ';
        }
        if(someDim4 == null ) {         
            error += 'Other ' + subaccount.substring(0,3) + ' is invalid. ';
        }    
        Import_Error__c newError = new Import_Error__c(User__c = user, Reason__c = error);
        insert newError;
    }
}