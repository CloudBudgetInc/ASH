public class ashSCRpostMatchQueueable implements Queueable {
    private static final Integer MAX_RETRIES = 3; // Maximum number of retries
    private ID creditNoteId;
    private Integer retries = 0;

    // Constructor
    public ashSCRpostMatchQueueable(ID creditNoteId) {
        this.creditNoteId = creditNoteId;
    }

    // Additional constructor to handle retries
    private ashSCRpostMatchQueueable(ID creditNoteId, Integer retries) {
        this.creditNoteId = creditNoteId;
        this.retries = retries;
    }
    
    public void execute(QueueableContext context) {
        try {                        
            // Now post and match the sales credit note
            c2g.PostAndMatchPxService.postAndMatchSync(creditNoteId);
            System.debug('Successfully posted and matched the Sales Credit Note.');
        } catch (Exception e) {
            System.debug('Error posting and matching the Sales Credit Note: ' + e.getMessage());
            if (retries < MAX_RETRIES) {
                System.enqueueJob(new ashSCRpostMatchQueueable(creditNoteId, retries + 1));
            } else {
                // Consider logging the final failure to a persistent store
                System.debug('Max retries reached. Giving up on creditNoteId: ' + creditNoteId);
            }
        }
    }
}