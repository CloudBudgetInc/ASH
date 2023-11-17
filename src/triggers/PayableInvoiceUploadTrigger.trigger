trigger PayableInvoiceUploadTrigger on Payable_Invoice_Upload__c (after update) {

    if (Trigger.isAfter && trigger.isUpdate )
    {
        for(Payable_Invoice_Upload__c upload : trigger.new) {
            
            if(Trigger.oldMap.get(upload.Id).Process_File__c != upload.Process_File__c ) {
                
        		FfaDataProvider dataProvider = FfaDataProvider.getInstance();
                boolean importFailed = false;
                
                // Fetch the CSV attached to the Payable Invoice Upload item.
                Id someId = upload.Id;
                List<ContentDocumentLink> someList = [SELECT Id, LinkedEntityId, ContentDocumentId
                                                      FROM ContentDocumentLink WHERE LinkedEntityId = :someId];  
                ContentDocumentLink cdl = someList.get(0);
                Id contentDocumentId = cdl.ContentDocumentId;
                ContentVersion someCv = [SELECT FileExtension, Title, versiondata FROM ContentVersion 
                                         WHERE ContentDocumentId = :contentDocumentId and IsLatest=true];
                Blob csvFileBody = someCv.VersionData;
                String csvAsString = csvFileBody.toString();
                List<String> csvFileLines = csvAsString.split('\n');
                
                // Grab the header line, then remove it so it is gone when we iterate thru the invoice lines.
                String headerLine = csvFileLines.get(0);
                List<String> headerSplits = headerLine.split(',');
                csvFileLines.remove(0);

                c2g__codaPurchaseInvoice__c  thisInvoice = new c2g__codaPurchaseInvoice__c();
                thisInvoice.Type__c = 'Invoice';
                thisInvoice.c2g__OwnerCompany__c = upload.Accounting_Company__c; 
                thisInvoice.c2g__DeriveCurrency__c = true;
                thisInvoice.c2g__Period__c = upload.Period__c;
                thisInvoice.c2g__DerivePeriod__c = false;
                thisInvoice.c2g__InvoiceDate__c = Date.today();
                thisInvoice.c2g__AccountInvoiceNumber__c = 'GTA/Amex - ' + Date.today().format();
                thisInvoice.c2g__InvoiceDescription__c = 'GTA/American Express - ' + Date.today().format();
                thisInvoice.c2g__Account__c = dataProvider.getVendor('AMER01').Id;
                insert thisInvoice;

                List<c2g__codaPurchaseInvoiceExpenseLineItem__c> linesForInsert = new List<c2g__codaPurchaseInvoiceExpenseLineItem__c>();                 
                for(String line : csvFileLines) {
                    
                    c2g__codaPurchaseInvoiceExpenseLineItem__c invoiceLine = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
                    invoiceLine.c2g__PurchaseInvoice__c  = thisInvoice.Id;    
                    List<String> moreSplits = line.split(',');
                    
                    Integer i = 0;
					c2g__codaDimension2__c dimension2;
                    Decimal netValue = 0.00;          
                    // Loop each column.
                    for( String more : moreSplits) {
                        if( i == 0 ) { 
                            invoiceLine.c2g__GeneralLedgerAccount__c = dataProvider.getGlaCode(more.substring(0,4));
                        }
                        else if( i == 1 ) {
                            c2g__codaDimension1__c dimension1 = dataProvider.getFullDimension1(more.substring(0,3));
                            dimension2 = dataProvider.getFullDimension2(more.substring(4,7));
							c2g__codaDimension3__c dimension3 = dataProvider.getFullDimension3(more.substring(8,11));
                            c2g__codaDimension4__c dimension4 = dataProvider.getFullDimension4(more.substring(12,14));                                  
                            
                            if( dimension1 == null || dimension2 == null || dimension3 == null || dimension4 == null ) {
                                Id thisUser = UserInfo.getUserId();
                                CodeErrorHandler.handleDimensionErrors(thisUser, more, dimension1, dimension2, dimension3, dimension4);
                                importFailed = true;
                                break; 
                            }
                                 
                            invoiceLine.c2g__Dimension1__c = dimension1.Id;
                            invoiceLine.c2g__Dimension2__c = dimension2.Id;
                            invoiceLine.c2g__Dimension3__c = dimension3.Id;
                            invoiceLine.c2g__Dimension4__c = dimension4.Id;
                            
                            // ASHRC has designated programs, therefore we change certain values to intercompany 
                            // if the Program is flagged as ASHRC.
                            if(dimension2.ASHRC__c == true ) {
                                invoiceLine.c2g__DestinationCompany__c = dataProvider.getCompany('ASHRC');
                            }                               
                        }      
                        if( i == 2 && !importFailed ) { 
                            invoiceLine.c2g__NetValue__c = Decimal.valueOf(more);
                            netValue = Decimal.valueOf(more);
                            // ASHRC has designated programs, therefore we change certain values to intercompany 
                            // if the Program is flagged as ASHRC.
                            if(dimension2.ASHRC__c == true ) {
                                invoiceLine.c2g__DestinationNetValue__c = netValue;
                            }                                    
                        }
                        else if( i == 3 && !importFailed ) { 
                            invoiceLine.c2g__LineDescription__c  = more; 
                        }
                        i++;
                    }
                    linesForInsert.add(invoiceLine);
               }
               if( !importFailed ) {
					insert linesForInsert;
			   }
            }
        }
    }
}