public with sharing class ashCashEntryCancellationService implements Queueable {

    public class CancelCashEntryRequest {
        @InvocableVariable(required=true)
        public Id OriginalCashEntryId;

        @InvocableVariable(required=true)
        public Id PeriodId;
    }
    
    private List<CancelCashEntryRequest> requests;

    public ashCashEntryCancellationService(List<CancelCashEntryRequest> reqs) {
        this.requests = reqs;
    }

    public void execute(QueueableContext context) {
        CancelCashEntryRequest req = requests[0]; // one record at a time from Flow
        cancelCashEntries(req.OriginalCashEntryId, req.PeriodId);
    }

    private void cancelCashEntries(Id originalCashEntryId, Id periodId) {
        System.debug('Initiating cash entry cancellation process for CashEntryId: ' + originalCashEntryId + ' and PeriodId: ' + periodId);
        
        try {
            c2g.CashEntryService.CancelCashEntryInfo cancelCashEntryInfo = new c2g.CashEntryService.CancelCashEntryInfo();
            cancelCashEntryInfo.OriginalCashEntryId = originalCashEntryId;
            cancelCashEntryInfo.PeriodId = periodId;
            cancelCashEntryInfo.Reference = 'Cancellation of Cash Entry'; 
            cancelCashEntryInfo.Description = 'Cancelling the original cash entry due to Refund.';

            List<Id> cancellingCashEntryIdList = c2g.CashEntryService.cancelCashEntries(
                new List<c2g.CashEntryService.CancelCashEntryInfo>{cancelCashEntryInfo}
            );

            System.debug('Successfully cancelled cash entry. Cancelling Cash Entry IDs: ' + cancellingCashEntryIdList);
        } catch(Exception e) {
            System.debug('Error encountered during cash entry cancellation: ' + e.getMessage());
            // Further error handling can be done here as required. 
        }
    }

    @InvocableMethod(label='Cancel Cash Entry')
    public static void invokeFromFlow(List<CancelCashEntryRequest> reqs) {
        ashCashEntryCancellationService service = new ashCashEntryCancellationService(reqs);
        System.enqueueJob(service);
    }
}