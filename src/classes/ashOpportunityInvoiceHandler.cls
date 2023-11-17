@RestResource(urlMapping='/InvoiceService/*')
global class ashOpportunityInvoiceHandler {
    
    Global class FlowInput {
        @InvocableVariable(label='Opportunity ID' required=true)
        Global Id oppId;

        @InvocableVariable(label='Post Invoice' required=false)
        Global Boolean isInvoicePosted;

        @InvocableVariable(label='Invoice Type' required=false)
        Global String invoiceType;

        @InvocableVariable(label='SIN ID' required=false)
        Global Id sinId;

        @InvocableVariable(label='Sync SIN' required=false)
        Global Boolean sinSynced; 
        
    }
    
    global class FlowResponse {
        @InvocableVariable
        Global String invoiceId;
		
		@InvocableVariable
    	Global String paymentURL;
    }
  
    @InvocableMethod(label='Generate Invoice' description='Generates an Invoice from the provided Opportunity ID and options')
    Global static List<FlowResponse> createInvoice(List<FlowInput> inputs) {
        
        FlowResponse response = new FlowResponse();
        List<FlowResponse> responses = new List<FlowResponse>();
        
        // Considering a single record for simplicity. Could be enhanced for bulk processing.
        Id oppId = inputs[0].oppId;
        Id sinId = inputs[0].sinId;
        Boolean sinSynced = inputs[0].sinSynced;
        Boolean shouldPost = inputs[0].isInvoicePosted != null ? inputs[0].isInvoicePosted : false; // Default to false if not provided
        String invType = inputs[0].invoiceType != null ? inputs[0].invoiceType : 'Default'; // Default to 'Default' if not provided
        
        try {
            Opportunity opp = [SELECT Id, CloseDate, AccountId, HasOpportunityLineItem FROM Opportunity WHERE Id = :oppId LIMIT 1];
            Account relatedAccount = [SELECT Id, FirstName__c, LastName__c, BillingStreet, BillingCity, BillingState, BillingCountry,   
                                      BillingPostalCode, c2g__CODADimension1__c, c2g__CODADimension2__c, c2g__CODADimension3__c, 
                                      c2g__CODADimension4__c FROM Account WHERE Id = :opp.AccountId LIMIT 1];
    
            c2g__codaInvoice__c invoice = new c2g__codaInvoice__c();
            
           string companyFFA = 'a7s3u0000008eakAAA'; //Hard codded the Owner Compnay here..need to update this with the FF Fondation Company 
            
            // Getting time period
            c2g__codaPeriod__c periodRecord = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__StartDate__c <= :opp.CloseDate AND c2g__EndDate__c >= :opp.CloseDate AND c2g__OwnerCompany__c = :companyFFA LIMIT 1];
                
        
            // Mapped values
                invoice.c2g__Opportunity__c = opp.Id;
                invoice.c2g__Account__c = opp.AccountId;
                invoice.c2g__Dimension1__c = relatedAccount.c2g__CODADimension1__c;
                invoice.c2g__Dimension2__c = relatedAccount.c2g__CODADimension2__c;
                invoice.c2g__Dimension3__c = relatedAccount.c2g__CODADimension3__c;
                invoice.c2g__Dimension4__c = relatedAccount.c2g__CODADimension4__c;
                invoice.c2g__FirstDueDate__c = opp.CloseDate;
                invoice.c2g__InvoiceDate__c = opp.CloseDate;
                invoice.c2g__DueDate__c = opp.CloseDate.addDays(30); // accountMap.get(opp.AccountId).c2g__CODADaysOffset1__c Assumed mapping; might need adjustment
                invoice.c2g__Period__c = periodRecord.Id;
            	invoice.ASH_Invoice_Type__c = invType;
                   
                invoice.c2g__OwnerCompany__c = companyFFA;
                //invoice.c2g__OwnerCompany__c = companyFFA.c2g__msg_link_ffa_id__c;
                
                
                // Hard codded
                invoice.c2g__CopyAccountValues__c = FALSE;
                invoice.c2g__CopyDefaultPrintedTextDefinitions__c = FALSE;
                invoice.c2g__CreatingRecurringInvoice__c = FALSE;
                invoice.c2g__DeriveCurrency__c = FALSE;
                invoice.c2g__DeriveDueDate__c = FALSE;
                invoice.c2g__DerivePeriod__c = FALSE;
                invoice.c2g__GenerateAdjustmentJournal__c = TRUE;
                invoice.c2g__Interval__c = 'Monthly';
                invoice.c2g__InvoiceCurrencyDecimalPlaces__c = 2;
                invoice.c2g__InvoiceCurrency__c = 'a7X3u000000XednEAC'; // need to look at
                invoice.c2g__InvoiceStatus__c = 'In Progress';
                invoice.c2g__InvoiceType__c = 'Standard';
                invoice.c2g__PrintedText1AllowEdit__c = FALSE;
                invoice.c2g__PrintedText2AllowEdit__c = FALSE;
                invoice.c2g__PrintedText3AllowEdit__c = FALSE;
                invoice.c2g__PrintedText4AllowEdit__c = FALSE;
                invoice.c2g__PrintedText5AllowEdit__c = FALSE;
                invoice.c2g__PrintStatus__c = 'Not Printed';
                invoice.c2g__SalesTaxStatus__c = 'Not Calculated';
                invoice.c2g__Usepartperiods__c = TRUE;          
                invoice.CurrencyIsoCode = 'USD';
                invoice.ffaci__CongaPrintStatus__c = 'Not Printed';
                invoice.ffaci__CurrencyCulture__c = 'en-AU';    // need to look at
                invoice.ffbext__Approved__c = FALSE;
                //invoice.ffgcp__CloudPrintStatus__c = 'Unavailable';   
    
           // invoicesToInsert.add(invoice);
            if (sinId != null && sinSynced) {
            invoice.Id = sinId;
			// checking the existing invoice. 
			c2g__codaInvoice__c existingInvoice = [SELECT ASH_Invoice_Type__c FROM c2g__codaInvoice__c  WHERE Id = :sinId LIMIT 1];
                if (existingInvoice != null) {
                    if(invType == 'Default') invoice.ASH_Invoice_Type__c = existingInvoice.ASH_Invoice_Type__c; 
                    
                    update invoice; // Updating existing Invoice
                    // deleting existing line items. 
                    List<c2g__codaInvoiceLineItem__c> existingLineItems = [SELECT Id FROM c2g__codaInvoiceLineItem__c WHERE c2g__Invoice__c = :sinId];
                    delete existingLineItems;                
                  }
            
                

            }
            else{
            insert invoice;
            }
            response.invoiceId = invoice.Id;  // Setting the returned invoice ID to the response.
            response.paymentURL = '';

             // ********************************************************************************* Adding Invoice Line Items
            if(opp.HasOpportunityLineItem) {    
            List<OpportunityLineItem> oppLineItems = [SELECT Description, Product2Id, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :oppId];
    
            List<c2g__codaInvoiceLineItem__c> lineItemsToInsert = new List<c2g__codaInvoiceLineItem__c>();
    
            Integer lineNumber = 1; // Initialize line number
            for(OpportunityLineItem oli : oppLineItems) {
            
                c2g__codaInvoiceLineItem__c lineItem = new c2g__codaInvoiceLineItem__c();
    
                
                lineItem.c2g__CalculateIncomeSchedule__c = FALSE;
                lineItem.c2g__CalculateTaxValue1FromRate__c = FALSE;
                lineItem.c2g__CalculateTaxValue2FromRate__c = FALSE;
                lineItem.c2g__CalculateTaxValue3FromRate__c = FALSE;
                lineItem.c2g__DeriveLineNumber__c = FALSE;
                lineItem.c2g__DeriveTaxRate1FromCode__c = FALSE;
                lineItem.c2g__DeriveTaxRate2FromCode__c = FALSE;
                lineItem.c2g__DeriveTaxRate3FromCode__c = FALSE;
                lineItem.c2g__DeriveUnitPriceFromProduct__c = FALSE;
                
                // lineItem.c2g__Dimension1__c = ''; // this will be set later or has a default value
                // lineItem.c2g__Dimension2__c = ''; // this will be set later or has a default value
                // lineItem.c2g__Dimension3__c = ''; // this will be set later or has a default value
                // lineItem.c2g__Dimension4__c = ''; // this will be set later or has a default value
                
                lineItem.c2g__ExcludeFromWithholding__c = FALSE;
                lineItem.c2g__InternalCalculateIS__c = TRUE;
                lineItem.c2g__InvoiceCurrencyDecimalPlaces__c = 1;
                lineItem.c2g__SetTaxCode1ToDefault__c = FALSE;
                lineItem.c2g__SetTaxCode2ToDefault__c = FALSE;
                lineItem.c2g__SetTaxCode3ToDefault__c = FALSE;
                lineItem.c2g__UsePartPeriods__c = TRUE;
                lineItem.c2g__UseProductInformation__c = FALSE;
                lineItem.CurrencyIsoCode = 'USD';
                
                
                lineItem.c2g__OwnerCompany__c = companyFFA; // needed to change this
                
                lineItem.c2g__Invoice__c = invoice.Id; // Linking the line item to the invoice you just created
                // Mapping the OpportunityLineItem fields to c2g__codaInvoiceLineItem__c
                lineItem.c2g__LineDescription__c = oli.Description;
                lineItem.c2g__Product__c = oli.Product2Id;
                lineItem.c2g__Quantity__c = oli.Quantity;
                lineItem.c2g__UnitPrice__c = oli.UnitPrice;
                lineItem.c2g__LineNumber__c = lineNumber++; // Increment the line number for each line item.
    
                // Add the line item to the list to insert.
                lineItemsToInsert.add(lineItem);
            }
    
            // Insert all the line items at once.
            if(lineItemsToInsert.size() > 0) {
                insert lineItemsToInsert;
            }
            }
            if(shouldPost) {
                Set<Id> sourceIds = new Set<Id>{invoice.Id}; // Using the newly created invoice's Id
                Set<Id> transactionIds;
                try {
                    transactionIds = c2g.PostingPxService.postSync(sourceIds);
                    System.debug('Transactions created: ' + transactionIds);
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Error while posting the Sales Invoice: ' + e.getMessage());
                }
            }
            // Between Start
            if(shouldPost && invType == 'Website Donation') { // Updating the Payment type to Website Donation on the Asperato Payment Object.
                try {        
                    c2g__codaInvoice__c postedInvoice = [SELECT ffasp__Payment__c FROM c2g__codaInvoice__c WHERE Id = :invoice.Id LIMIT 1];
            
                    if(postedInvoice != null && postedInvoice.ffasp__Payment__c != null) {
                        
                        asp04__Payment__c relatedRecord = [SELECT id, asp04__eCommerce_URL__c, ASH_Payment_Type__c FROM asp04__Payment__c WHERE Id = :postedInvoice.ffasp__Payment__c LIMIT 1];
                        
                        if(relatedRecord != null) {
                            String html_eCommerce_URL = relatedRecord.asp04__eCommerce_URL__c;
                            //Pattern p = Pattern.compile('<a[^>]*>(.*?)</a>');
                            Pattern p = Pattern.compile('<a[^>]+href="([^">]+)"[^>]*>(.*?)</a>');
                            Matcher m = p.matcher(html_eCommerce_URL);
                            
                            String extractedURL;
                            if (m.find()) {
                                extractedURL = m.group(1);
                                response.paymentURL = extractedURL.replace('&amp;', '&');
                                System.debug('paymentURL: ' + extractedURL);
                            }
                            
                            relatedRecord.ASH_Payment_Type__c = 'Website Donation';
                            update relatedRecord;
                        }
                    }
                } catch(QueryException qe) {
                    System.debug('Query Exception when trying to update related record: ' + qe.getMessage());
                } catch(DmlException dmlE) {
                    System.debug('DML Exception when trying to update related record: ' + dmlE.getMessage());
                }
            } 
            
            

        } // Between End
        catch(QueryException qe) {
            System.debug('Query Exception: ' + qe.getMessage());
            // Handle or log the error appropriately
        } catch(DmlException dmlE) {
            System.debug('DML Exception: ' + dmlE.getMessage());
            // Handle or log the error.
        } catch(Exception e) {
            System.debug('General Exception: ' + e.getMessage());
            // Handle or log the general exception.
        }
        
        responses.add(response);
        System.debug('responses' + responses);
        return responses; 
    }

    @HttpPost
    global static FlowResponse createInvoiceFromREST() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
     
        // Deserialize the request JSON body into the FlowInput class
        FlowInput input = (FlowInput) JSON.deserialize(req.requestBody.toString(), FlowInput.class);

        // Call your original method
        List<FlowResponse> responses = createInvoice(new List<FlowInput>{input});
        
        // Assuming that there will always be at least one response.
        // Adjust error handling as necessary.
        System.debug('responses' + responses[0]); 
        return responses[0];
    }

}