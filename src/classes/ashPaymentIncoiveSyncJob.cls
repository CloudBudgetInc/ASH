global class ashPaymentIncoiveSyncJob implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        processInvoices();
    }
    
    public void processInvoices() {
        try {
            // Retrieve the custom setting value
            ash_ar_custom_settings__c customSetting = ash_ar_custom_settings__c.getInstance('Default');
            Integer daysThreshold = (Integer) customSetting.Unpaid_Website_Donations_keep_in_syst__c;
    
            // If the custom setting is not set, set a default value
            if(daysThreshold == null) {
                daysThreshold = 7;
            }
    
            Date thresholdDate = Date.today().addDays(-daysThreshold);
            
            System.debug('Threshold Date for Discarding or Converting to SCR:'+ thresholdDate);
    
            // SOQL query to retrieve the invoices based on the criteria
            List<c2g__codaInvoice__c> invoices = [SELECT Id, Name, c2g__InvoiceStatus__c, c2g__PaymentStatus__c, ffasp__Payment__c, 
                                                     ffasp__Payment__r.asp04__Payment_Stage__c, c2g__InvoiceDate__c, c2g__CompanyReference__c
                                              FROM c2g__codaInvoice__c
                                              WHERE ffasp__Payment__c != NULL AND c2g__InvoiceStatus__c = 'Complete' AND ASH_Invoice_Type__c = 'Website Donation' AND c2g__PaymentStatus__c != 'Paid'];

            if(invoices.isEmpty()) {
                System.debug('No invoices found matching the criteria.');
                return;
            }

            for(c2g__codaInvoice__c inv : invoices) {
                if(inv.c2g__InvoiceStatus__c == 'Complete' && inv.c2g__PaymentStatus__c == 'Unpaid' && inv.ffasp__Payment__r.asp04__Payment_Stage__c == 'Collected from customer') {
                    // Actions for unmatched payment
                    System.debug('Unmatched Payment: Invoice Number: ' + inv.Name + ', Payment Number: ' + inv.ffasp__Payment__r.Name);
                }
                else if(inv.c2g__InvoiceStatus__c == 'Complete' && 
                        (inv.ffasp__Payment__r.asp04__Payment_Stage__c == 'Awaiting submission' || inv.ffasp__Payment__r.asp04__Payment_Stage__c == 'Failed') && 
                        inv.c2g__InvoiceDate__c <= thresholdDate) {
                    // Actions for failed or awaiting payment for invoices older than the threshold
                    // Start the queueable chain
                    String companyName = inv.c2g__CompanyReference__c;
                    System.enqueueJob(new ashSetCompanyQueueable(companyName, inv.Id)); // Passing company name and invoice ID
                    System.debug('Failed/Awaiting Payment: Invoice Number: ' + inv.Name + ', Payment Number: ' + inv.ffasp__Payment__c);         
                }
            }

        } catch(Exception e) {
            // Handle the exception and log it
            System.debug('Error in processInvoices: ' + e.getMessage());
            // Optionally, you can use System.LoggingLevel.ERROR for more visibility:
            // System.debug(System.LoggingLevel.ERROR, 'Error in processInvoices: ' + e.getMessage());
        }
    }
}