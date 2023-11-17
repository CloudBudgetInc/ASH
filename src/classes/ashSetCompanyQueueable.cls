public class ashSetCompanyQueueable implements Queueable {

    private String companyName;
    private ID salesInvoiceId;

    // Updated constructor
    public ashSetCompanyQueueable(String companyName, ID salesInvoiceId) {
        this.companyName = companyName;
        this.salesInvoiceId = salesInvoiceId;
    }

    public void execute(QueueableContext context) {
        try {
            List<String> companiesToSet = new List<String>();
            companiesToSet.add(companyName);
            c2g.CODAAPICompany_2_0.SetCurrentCompanies(companiesToSet);
            
            System.debug('Company set to: ' + companyName);

            // Enqueue next job in the chain
            System.enqueueJob(new ashSCRconvertQueueable(salesInvoiceId));

        } catch (Exception e) {
            System.debug('Error setting company: ' + e.getMessage());
        }
    }
}