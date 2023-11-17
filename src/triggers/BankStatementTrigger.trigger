trigger BankStatementTrigger on Bank_Statement__c (after update) {
    
    if ( Trigger.isAfter && trigger.isUpdate ) 
    {
        // Sets up a look of BAI type code matched to BAI type description.
        Map<String, BAITransactionType__c> transactionTypeLookup = new Map<String, BAITransactionType__c>();
        Map<Id, BAITransactionType__c> someTransactionTypes = 
            new Map<Id, BAITransactionType__c>([SELECT Id, Code__c, Type__c from BAITransactionType__c]);
		for( Id someId : someTransactionTypes.keySet() ) {
    		BAITransactionType__c transactionType = someTransactionTypes.get(someId);
            String code = transactionType.Code__c;
		    transactionTypeLookup.put(code, transactionType);
		}
        
        for(Bank_Statement__c statement : trigger.new) {

            if( statement.Process_File__c == true && 
				Trigger.oldMap.get(statement.Id).Process_File__c != statement.Process_File__c ) {
					if(statement.Format__c == 'BAI') { 
						importBAIFormattedFile(statement, transactionTypeLookup);
                    } else
                    {
                        importCVSFormattedFile(statement);
                    }
            	}
        }
    }
    
    private void importBAIFormattedFile(Bank_Statement__c statement, Map<String, BAITransactionType__c> transactionTypeLookup)
    {
        // Fetch the file attached to the Bank Statement item, and split based on newlines.
        Id someId = statement.Id;
        List<ContentDocumentLink> someList = [SELECT Id, LinkedEntityId, ContentDocumentId
                                              FROM ContentDocumentLink WHERE LinkedEntityId = :someId];  
        ContentDocumentLink cdl = someList.get(0);
        Id contentDocumentId = cdl.ContentDocumentId;
        ContentVersion someCv = [SELECT FileExtension, Title, versiondata FROM ContentVersion 
                                 WHERE ContentDocumentId = :contentDocumentId and IsLatest=true];
        Blob csvFileBody = someCv.VersionData;
        String csvAsString = csvFileBody.toString();
        List<String> csvFileLines = csvAsString.split('\n');
        
        // Grab the header lines, then remove them (for now)
        //csvFileLines.remove(0);
        //csvFileLines.remove(1);
        //csvFileLines.remove(3);
        
        String bankAccountNumber = statement.Bank_Account_Number__c;
        List<Bank_Statement_Line_Item__c> linesForInsert = new List<Bank_Statement_Line_Item__c>();                 
        
        boolean process = false;
        String transactionDate = '';
        for(String line : csvFileLines) {
            // File is grouped by date using the 02 record.
            if(line.startsWith('02')) {
                List<String> moreSplits = line.split(',');
                transactionDate = moreSplits[4];                        
            }
            // File is further grouped by bank account number - only process records that match 
            // the bank account number set on the object.
            if( line.startsWith('03') ) {
                List<String> moreSplits = line.split(',');
                if(moreSplits[1].equals(bankAccountNumber)) {
                    process = true;
                }
                else {
                    process = false;
                }    
            }
            // 16 is a data transaction; we load these up for matching purposes.
            // Here we're finally doing "the work" of this trigger.
            if(line.startsWith('16') && process == true) { 
                List<String> moreSplits = line.split(',');
                Bank_Statement_Line_Item__c newLine = new Bank_Statement_Line_Item__c();
                String code = moreSplits[1];
                // If we don't have a lookup value for the BAI type, we still process it - 
                // we just set it as 'unknown'.
                BAITransactionType__c typeLookup = transactionTypeLookup.get(code);
                if(typeLookup == null) {
                    typeLookup = transactionTypeLookup.get('999');
                }
                newLine.Type__c = typeLookup.Type__c;
                newLine.Code__c = code;
                // We use BAI standards to determine the sign of the transaction item.
                if(Integer.valueOf(code) < 400) { 
                    newLine.Amount__c = (Decimal.valueOf(moreSplits[2])/100);
                    newLine.Sign__c = 'Debit';
                }
                else {
                    newLine.Amount__c = (Decimal.valueOf(moreSplits[2])/100) * -1;
                    newLine.Sign__c = 'Credit';
                }
                newLine.Reference__c = moreSplits[4];
                String addenda1 = moreSplits[5];
                // Special handling for checks - grab the check number.
                if(code == '475') {
                    newLine.Addenda_1__c = addenda1.left(5);                        
                }
                newLine.Bank_Statement__c = statement.Id;
                newLine.Transaction_Date__c = 
                    Date.newInstance(Integer.valueOf('20' + transactionDate.left(2)), 
                                     Integer.valueOf(transactionDate.mid(2,2)), 
                                     Integer.valueOf(transactionDate.right(2)));
                linesForInsert.add(newLine);
            }
        }
        insert linesForInsert;
    }
    
    private void importCVSFormattedFile(Bank_Statement__c statement) {
        
        // fetch the CSV attached to the Bank Statement.
        Id someId = statement.Id;
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

        List<Bank_Statement_Line_Item__c> linesForInsert = new List<Bank_Statement_Line_Item__c>();         
        for( String line : csvFileLines ) {
            Bank_Statement_Line_Item__c newLine = new Bank_Statement_Line_Item__c(); 
            newLine.Bank_Statement__c = statement.Id;
            List<String> moreSplits = line.split(',');
            
            Integer i = 0;
            for( String more : moreSplits) {   
                //System.debug(more);
                String sign;
                if(i == 0) { 
                	newLine.Transaction_Date__c = Date.parse(more);
                }
                if(i == 2) { 
                    if(more != null && more != '') { 
                        newLine.Amount__c = (Decimal.valueOf(more) * -1);
                        newLine.Sign__c = 'Debit';
                    }
                }
                if(i == 3) { 
                    //System.debug(more);
                    if(more != null && more != '') {
                        newLine.Amount__c = Decimal.valueOf(more);
                        newLine.Sign__c = 'Credit';
                    }
                }
                if(i == 4) {
                    // Type. Need to figure out what to do here as the Atlantic Union list doesn't 
                    // cleanly align with the Truist list which is driven off a more traditional BAI standard.
                }     
                if(i == 5) {
                    newLine.Reference__c = more.left(50);
                }
                i++;
        	}
            linesForInsert.add(newLine);
        }
        insert linesForInsert;
    }
}