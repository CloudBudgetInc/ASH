public with sharing class ashRefundCreationService implements Queueable {

    public class RefundRequest {
        @InvocableVariable(required=true)
        public String paymentId;
        
        @InvocableVariable(required=true)
        public Decimal amount;
        
        @InvocableVariable(required=false)
        public Boolean processRefundImmediately;
    }

    private List<RefundRequest> queueableRequests;

    public ashRefundCreationService(List<RefundRequest> requests) {
        this.queueableRequests = requests;
    }

    public void execute(QueueableContext context) {
        processRefund(queueableRequests);
    }

    private void processRefund(List<RefundRequest> requests) {
        List<String> responseList = new List<String>();
        RefundRequest request = requests[0];

        try {
            asp04__Payment__c payment = [SELECT Id, asp04__Amount__c, asp04__Payment_Stage__c, asp04__Payment_Route_Selected__c, asp04__Total_Refunded__c FROM asp04__Payment__c WHERE Id = :request.paymentId];
            
            // Validations
            if(payment.asp04__Payment_Stage__c != 'Collected from customer') {
                throw new CustomException('Payment Stage must be "Collected from customer" to process a refund.');
            }

            Decimal refundAmount;
            Decimal refundAvailable = payment.asp04__Amount__c - payment.asp04__Total_Refunded__c;
            if(request.amount == 0) {
                refundAmount = refundAvailable;
            } else {
                refundAmount = request.amount;
            }
            
            if(refundAmount > refundAvailable) {
                throw new CustomException('Refund Amount cannot be greater than the Payment Amount.');
            }

            asp04__Refund__c newRefund = new asp04__Refund__c(
                asp04__Actual_Refund_Date__c = Date.today(),
                asp04__Amount__c = refundAmount,
                asp04__Payment__c = request.paymentId,
                asp04__Refund_Stage__c = 'New',
                asp04__Payment_Route__c = payment.asp04__Payment_Route_Selected__c
            );

            insert newRefund;

            if (request.processRefundImmediately == true) {
                asp04.BatchSendRefunds refundBatch = new asp04.BatchSendRefunds(new List<Id>{newRefund.Id});
                Database.executeBatch(refundBatch);
            }
            
            c2g__codaCashEntry__c cashEntry = [SELECT Id, c2g__OwnerCompany__c FROM c2g__codaCashEntry__c WHERE ffasp__Payment__c = :request.paymentId LIMIT 1];
            if(cashEntry != null) { 
                c2g__codaPeriod__c periodRecord = [SELECT Id FROM c2g__codaPeriod__c WHERE c2g__StartDate__c <= :Date.today() AND c2g__EndDate__c >= :Date.today() AND c2g__OwnerCompany__c = :cashEntry.c2g__OwnerCompany__c LIMIT 1];    
                ashCashEntryCancellationService.CancelCashEntryRequest cancelReq = new ashCashEntryCancellationService.CancelCashEntryRequest();
                cancelReq.OriginalCashEntryId = cashEntry.Id;
                cancelReq.PeriodId = periodRecord.Id;
                ashCashEntryCancellationService service = new ashCashEntryCancellationService(new List<ashCashEntryCancellationService.CancelCashEntryRequest>{cancelReq});
                System.enqueueJob(service);
            }

            responseList.add(newRefund.Id);
        } catch(Exception e) {
            responseList.add('Error: ' + e.getMessage());
        }
    }

    @InvocableMethod(label='Enqueue Refund Record Creation')
    public static List<String> enqueueRefundCreation(List<RefundRequest> requests) {
        ashRefundCreationService job = new ashRefundCreationService(requests);
        System.enqueueJob(job);
        
        // Return a generic response or modify as needed
        return new List<String> { 'Refund processing enqueued.' };
    }

    public class CustomException extends Exception {}
}