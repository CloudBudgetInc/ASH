Global class GAUAllocationTriggerHelper {
    
    
    
    Global static void createGAUProducts( Map<Id,npsp__Allocation__c> newItems){
        try{
        List<Id> OpportunityIds = new List<Id>();
        Map<String,String> OpportunityRecordTypeMap = new Map<String,String>();
        Map<String,String> AccountRecordTypeMap = new Map<String,String>();
        Map<Id,List<String>> OpportunityPaymentMethodmap = new Map<Id,List<String>>();
        Map<String, String> paymentMethodsMap = new Map<String, String>();
        Map<Id, List<String>> OpportunityProductCodeMap = new Map<Id, List<String>>();
        Map<Id, List<String>> OpportunityDataMap = new Map<Id, List<String>>();
        Map<Id, List<Id>> gauOpptyMap = new Map<Id, List<Id>>();
        Map<String, Id> gauLabelMap = new Map<String, Id>();
        Map<String, string> productCodeMap = new Map<String, string>();
        Map<Id, Id>PricebookEntryMap = new Map<Id, Id>();
        Set<String> allCodes = new Set<String>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        //String Json = {'Dummy',true,'Dummy','Dummy',true};
        ashOpportunityInvoiceHandler.FlowInput  fip;// = new ashOpportunityInvoiceHandle.FlowInput();
        Decimal UnitPrice;
        String OpportunityId = [select npsp__Opportunity__r.Id from npsp__Allocation__c limit 1].npsp__Opportunity__r.Id;
        String Typeval       = [select Type from Opportunity where Id=: OpportunityId limit 1].Type;
        String Idval         = [select Id from Opportunity where  Id=: OpportunityId limit 1].Id;
        String SINId         = [select 	Donation_SIN__c from Opportunity where Id=: OpportunityId limit 1].Donation_SIN__c;
        String Opptype       = [select RecordType.Name from Opportunity where Id=: OpportunityId limit 1].RecordType.Name;
        Boolean InvoicePost  = true;
        List<ashOpportunityInvoiceHandler.FlowInput> collectVar;
        if(Typeval=='Online Giving' && Opptype=='Donation'){
            RestRequest req = RestContext.request;
            
          
            fip.oppId  = Idval;
            fip.invoiceType  =Typeval;
            fip.isInvoicePosted  = true;
            fip.sinId    =  SINId;
            fip.sinSynced  = true;
            collectVar.add(fip);
           
           ashOpportunityInvoiceHandler.createInvoice(collectVar);
        }
        else{
            
            UnitPrice = [select npsp__Amount__c FROM npsp__Allocation__c where Id =: newItems.Values() limit 1 ].npsp__Amount__c;
            List<OpportunityRecordTypeMapping__mdt> OpportunityTypeMappings = OpportunityRecordTypeMapping__mdt.getAll().values();
            List<Payment_Method__mdt> PaymentMethodMappings = Payment_Method__mdt.getAll().values();
            List<Account_Type__mdt> AccountTypeMappings = Account_Type__mdt.getAll().values();
            
            for(OpportunityRecordTypeMapping__mdt ort : OpportunityTypeMappings ){
                OpportunityRecordTypeMap.put(ort.MasterLabel, ort.Code__c);
                allCodes.add(ort.Code__c);
            }
            
            for(Account_Type__mdt art : AccountTypeMappings ){
                AccountRecordTypeMap.put(art.MasterLabel, art.Code__c);
                allCodes.add(art.Code__c);
            }
            
            for(Payment_Method__mdt pm : PaymentMethodMappings){
                paymentMethodsMap.put(pm.MasterLabel, pm.Code__c);
                allCodes.add(pm.Code__c);
            }
            
            for(npsp__Allocation__c a : newItems.Values()){
                if(gauOpptyMap.containsKey(a.npsp__General_Accounting_Unit__c)){
                    gauOpptyMap.get(a.npsp__General_Accounting_Unit__c).add(a.npsp__Opportunity__c);
                } else {
                    gauOpptyMap.put(a.npsp__General_Accounting_Unit__c, new List<Id>{a.npsp__Opportunity__c});
                }
                OpportunityIds.add(a.npsp__Opportunity__c);
            }
            
            for(npsp__General_Accounting_Unit__c gau : [SELECT Id, Name FROM npsp__General_Accounting_Unit__c WHERE Id IN :gauOpptyMap.keyset()]){
                gauLabelMap.put(gau.Name, gau.Id);
            }
            
            for(npe01__OppPayment__c o : [SELECT Id, npe01__Opportunity__c, npe01__Payment_Method__c FROM npe01__OppPayment__c WHERE npe01__Opportunity__c IN :OpportunityIds]){
                if(paymentMethodsMap.containsKey(o.npe01__Payment_Method__c)){
                    if(OpportunityPaymentMethodmap.containsKey(o.npe01__Opportunity__c)){
                        OpportunityPaymentMethodmap.get(o.npe01__Opportunity__c).add(paymentMethodsMap.get(o.npe01__Payment_Method__c));
                    } else {
                        OpportunityPaymentMethodmap.put(o.npe01__Opportunity__c, new List<String>{paymentMethodsMap.get(o.npe01__Payment_Method__c)});
                    }
                }
            }
            
            for(Opportunity o : [SELECT Id, Account.RecordType.Name, RecordType.Name FROM Opportunity WHERE Id IN :OpportunityIds]){
                List<String> codeList = new List<String>();
                String code = '';
                if(OpportunityRecordTypeMap.containskey(o.RecordType.Name)){
                    code += '_'+OpportunityRecordTypeMap.get(o.RecordType.Name);
                }
                if(code != '_PL'){
                    if(OpportunityPaymentMethodmap.containskey(o.Id)){
                        for(String pm : OpportunityPaymentMethodmap.get(o.Id)){
                            code += '_'+pm;
                            if(AccountRecordTypeMap.containskey(o.Account.RecordType.Name)){
                                code += '_'+AccountRecordTypeMap.get(o.Account.RecordType.Name);
                            }
                            codeList.add(code);
                        }
                    } else if(AccountRecordTypeMap.containskey(o.Account.RecordType.Name)){
                        code += '_'+AccountRecordTypeMap.get(o.Account.RecordType.Name);
                        codeList.add(code);
                    } else if(String.isNotBlank(code)){
                        codeList.add(code);
                    }
                } else if(String.isNotBlank(code)) {
                    codeList.add(code);
                }
                if(codeList.isEmpty()){
                    OpportunityProductCodeMap.put(o.Id, new List<String>());
                } else {
                    OpportunityProductCodeMap.put(o.Id, codeList);
                }
            }
            
            
            
            if(!OpportunityProductCodeMap.isEmpty() && !gauLabelMap.isEmpty()){
                for(DataMapping__c p : [SELECT Id,General_Accounting_Unit__c,Parent_Code__c FROM DataMapping__c WHERE General_Accounting_Unit__c = :gauLabelMap.keyset()]){
                    for(Id opptyId : gauOpptyMap.get(gauLabelMap.get(p.General_Accounting_Unit__c))){
                        if(OpportunityProductCodeMap.get(opptyId).isEmpty()){
                            Boolean isValid = true;
                            for(String code : allCodes){
                                if(p.Parent_Code__c.endsWith(code)){
                                    isValid = false;
                                    break;
                                }
                            }
                            if(isValid){
                                productCodeMap.put(p.Parent_Code__c,'');
                                system.debug('productCode1: '+p.Parent_Code__c);
                                if(OpportunityDataMap.containsKey(opptyId)){
                                    OpportunityDataMap.get(opptyId).add(p.Parent_Code__c);
                                } else {
                                    OpportunityDataMap.put(opptyId, new List<String>{p.Parent_Code__c});
                                }
                            }
                        } else {
                            for(String code : OpportunityProductCodeMap.get(opptyId) ){
                                if(p.Parent_Code__c.endsWith(code)){
                                    system.debug('productCode2: '+p.Parent_Code__c);
                                    productCodeMap.put(p.Parent_Code__c,'');
                                    if(OpportunityDataMap.containsKey(opptyId)){
                                        OpportunityDataMap.get(opptyId).add(p.Parent_Code__c);
                                    } else {
                                        OpportunityDataMap.put(opptyId, new List<String>{p.Parent_Code__c});
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(!productCodeMap.isEmpty()){
                system.debug('productCodeMap: '+productCodeMap.keyset());
                for(Product2 pd : [Select Id,ProductCode from Product2 where ProductCode = :productCodeMap.keyset()]){
                    productCodeMap.put(pd.ProductCode, pd.Id);
                }
            }
            
            if(!productCodeMap.values().isEmpty()){
                for(PricebookEntry pbe : [SELECT Id, Product2Id FROM PricebookEntry where Pricebook2.Name='Standard Price Book' AND Product2Id = :productCodeMap.values()]){
                    PricebookEntryMap.put(pbe.Product2Id, pbe.Id);
                }
            }        
            
            if(!OpportunityDataMap.isEmpty()){
                
                for( Id opptyId : OpportunityDataMap.keyset()){
                    
                    
                    for(String productCode : OpportunityDataMap.get(opptyId)){
                        if(String.isNotBlank(productCodeMap.get(productCode)) && String.isNotBlank(PricebookEntryMap.get(productCodeMap.get(productCode)))){
                            OpportunityLineItem   oli = new OpportunityLineItem(
                                Product2Id = productCodeMap.get(productCode),
                                OpportunityId = opptyId,
                                PricebookEntryId = PricebookEntryMap.get(productCodeMap.get(productCode))
                            );
                            oli.UnitPrice  = UnitPrice;
                            oliList.add(oli);
                        }                    
                    }
                }
            }
            
            if(!oliList.isEmpty()){
                insert oliList;
            }
        }      
        }
         catch(Exception e){
            System.debug('Error in ScheduleCurrentSurvey '+e.getmessage()+' '+e.getLineNumber() +' StackTrace : '+e.getStackTraceString()); 
        }
   }
    
    
    
}