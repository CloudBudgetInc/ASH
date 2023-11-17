global class ashAsperatoWebRefundScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        try {
            processPayments();
        } catch(Exception e) {
            // Log the exception and send an email to the Salesforce admin (optional)
            System.debug('Error occurred: ' + e.getMessage());
            // Optionally, you can use Messaging.SingleEmailMessage to notify someone about this error.
        }
    }

    public void processPayments() {
        // Retrieve the custom setting value
        ash_ar_custom_settings__c setting = ash_ar_custom_settings__c.getInstance('Default');
        Integer daysToCheck = ((integer)setting.Refund_Unmathced_Website_Payment_Days__c != null) ? (integer)setting.Refund_Unmathced_Website_Payment_Days__c : 0;

        // Calculate the date to be checked
        Date checkDate = Date.today() - daysToCheck;
		System.debug('Threshold Date: to Issue Refund (YYYY-MM-DD) : ' + checkDate);
        // Query the records
        List<asp04__Payment__c> payments = [
            SELECT Id, ASH_Payment_Type__c, asp04__Payment_Stage__c 
            FROM asp04__Payment__c 
            WHERE ASH_Payment_Type__c = 'Website Donation' 
            AND asp04__Payment_Stage__c = 'Collected from customer' 
            AND asp04__Payment_Date__c <= :checkDate
            AND ffasp__SalesInvoice__c = null
            AND asp04__Total_Refunded__c = 0
        ];
        
        // Log the number of found records
        System.debug('Number of records found: ' + payments.size());

        // If there are records, then execute the required actions
        if(!payments.isEmpty()) {
            executeActions(payments);
        }
    }


	public void executeActions(List<asp04__Payment__c> payments) {
        
        // actions go here, calling the Refund creation service, that has been chained to cancel the Cash Entries. 
       

        for(asp04__Payment__c payment : payments) {
            try {
            List<ashRefundCreationService.RefundRequest> requests = new List<ashRefundCreationService.RefundRequest>();
            ashRefundCreationService.RefundRequest request = new ashRefundCreationService.RefundRequest();
            request.paymentId = payment.Id; // Pass the payment Id
            request.amount = 0;
            request.processRefundImmediately = true; // if you want to process the refund immediately

            System.debug('Payment ID: ' + payment.Id);
            
            requests.add(request);
            // Call the method
            List<String> responses = ashRefundCreationService.enqueueRefundCreation(requests);
        	System.debug('Refund Creation Responses: ' + responses);
            }
            catch (Exception e) {
            System.debug('Error processing refund for Payment ' + payment.Id + ': ' + e.getMessage());
        	}
            }

        
        
    }
}