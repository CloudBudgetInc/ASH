public class ashSCRconvertQueueable implements Queueable {

    private ID salesInvoiceId;

    // Constructor
    public ashSCRconvertQueueable(ID salesInvoiceId) {
        this.salesInvoiceId = salesInvoiceId;
    }
    
    public void execute(QueueableContext context) {
        try {            
            // Convert sales invoice to sales credit note
            ID creditNoteId = c2g.ConvertToCreditNotePxService.convertToSalesCreditNoteSync(salesInvoiceId);
            System.debug('Generated Sales Credit Note ID: ' + creditNoteId);

            // Enqueue next job in the chain
            System.enqueueJob(new ashSCRpostMatchQueueable(creditNoteId));

        } catch (Exception e) {
            System.debug('Error converting Sales Invoice to Sales Credit Note: ' + e.getMessage());
        }
    }
}