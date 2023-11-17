trigger JournalUploadTrigger on Journal_Upload__c (after update) {

    if (Trigger.isAfter && trigger.isUpdate ) 
    {
        FfaDataProvider provider = FfaDataProvider.getInstance();
        
        for(Journal_Upload__c upload:trigger.new)
        {
            if(Trigger.oldMap.get(upload.Id).Process_File__c  != upload.Process_File__c ) {
                
                // fetch the CSV attached to the Journal Upload item.
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
                
                // Grab the header line, then remove it so it is gone when we iterate thru the journal lines.
                String headerLine = csvFileLines.get(0);
                List<String> headerSplits = headerLine.split(',');
                csvFileLines.remove(0);
                
                c2g__codaJournal__c thisJournal = new c2g__codaJournal__c();
                thisJournal.c2g__Type__c = 'Manual Journal';
                thisJournal.c2g__OwnerCompany__c = upload.Accounting_Company__c; 
                thisJournal.c2g__DeriveCurrency__c = true;
                thisJournal.c2g__JournalDescription__c = headerSplits.get(1);
                if( upload.Special_Period__c == true ) {
        			thisJournal.c2g__DerivePeriod__c = false;
                    thisJournal.c2g__Period__c = upload.Period__c;
                    thisJournal.c2g__JournalDate__c = System.today();
                } else {
	                thisJournal.c2g__DerivePeriod__c = true;
    	            thisJournal.c2g__JournalDate__c = Date.parse(headerSplits.get(2));
                }
                insert thisJournal;                
                List<c2g__codaJournalLineItem__c> linesForInsert = new List<c2g__codaJournalLineItem__c>(); 
                
                for( String line : csvFileLines)
                {
                    c2g__codaJournalLineItem__c journalLine = new c2g__codaJournalLineItem__c();
                    journalLine.c2g__Journal__c = thisJournal.Id;    
                    journalLine.c2g__LineType__c = 'General Ledger Account';
                    List<String> moreSplits = line.split(',');
                    
                    Integer i = 0;
                    for( String more : moreSplits) {
                        if( i == 1 ) { journalLine.c2g__Value__c = Decimal.valueOf(more); }
                        else if( i == 2 ) { // debit/credit
                            if(more == 'C') { journalLine.c2g__Value__c = (journalLine.c2g__Value__c * -1); }
                        } 
                        else if( i == 4 ) { journalLine.c2g__LineDescription__c = more; }
                        else if( i == 5 ) {  
                            Id companyId = provider.getCompany(more);
                            // Only create intercompany if line company mismatches journal company.
                            if(companyId != upload.Accounting_Company__c) {
                                journalLine.c2g__LineType__c = 'Intercompany';
                                journalLine.c2g__DestinationCompany__c = provider.getCompany(more);
                                 journalLine.c2g__DestinationLineType__c = 'General Ledger Account';
                            }
                        }
                        else if( i == 9 ) { 
                            journalLine.c2g__GeneralLedgerAccount__c = provider.getGlaCode(more.substring(0,4));
                            journalLine.c2g__Dimension1__c = provider.getDimension1(more.substring(5,8));
                            journalLine.c2g__Dimension2__c = provider.getDimension2(more.substring(9,12));
                            journalLine.c2g__Dimension3__c = provider.getDimension3(more.substring(13,16));
                            journalLine.c2g__Dimension4__c = provider.getDimension4(more.substring(17,19));
                        }
                        i++;
                    }
                    linesForInsert.add(journalLine);
                }
                insert linesForInsert;
            }
        } 
    }
}