global class PersonnelBudgetStageBatch implements Database.Batchable<sObject> {

    String batchId;
    
    public PersonnelBudgetStageBatch(String batchId) {
        this.batchId = batchId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        
        String query = 'SELECT Id, Annual_Salary__c, Adjusted_Salary__c, Increased_Salary__c, Bonus__c, Bonus_Date__c,' + 
            'Review_Date__c, Hire_Date__c, Targeted_Increase__c, Medical_Dental_and_Vision__c, Benefits_Eligible__c, ' + 
            'Executive_Disability_Amount__c, Employer_457b_Contributions__c, Employee_Name__c ' + 
            'FROM Budget_Position__c WHERE Active__c = true';
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Budget_Position__c> positions) { 
        
        FfaDataProvider provider = FfaDataProvider.getInstance();
        
        List<Personnel_Budget_Batch__c> batches = [SELECT Id, X403b__c, X403b_Max__c,
              FUTA__c, FUTA_Max__c, SUTA__c, SUTA_Max__c, FICA__c, FICA_Max__c, PFML__c, Medicare__c, Year__c, 
              Basic_Life_AD_D_Max__c, Long_Term_Disability_Max__c
              FROM Personnel_Budget_Batch__c WHERE Id = :batchId];
        Personnel_Budget_Batch__c batch = batches.get(0);
        Integer year = Integer.valueOf(batch.Year__c);
        String company = 'ASH';
        
        // Pull together a lookup of periods by month, company. Period data is not company-specific 
        // so we simply use ASH for this.
	  	Map<Integer, c2g__codaPeriod__c> periodLookup = new Map<Integer, c2g__codaPeriod__c>();         
		Map<Id, c2g__codaPeriod__c> somePeriods = new Map<Id, c2g__codaPeriod__c>(
            [SELECT Id, c2g__StartDate__c, c2g__EndDate__c, c2g__OwnerCompany__r.Key__c, PerPost__c, c2g__PeriodNumber__c
             FROM c2g__codaPeriod__c WHERE Fiscal_Year__c = :year AND c2g__OwnerCompany__r.Key__c = :company 
             AND c2g__Description__c = 'Trading Period']);
        
        // Put results in a lookup of Periods, keyed by month number, i.e. 1, 2, 8, 10, 12 etc.
       	for( Id someId : somePeriods.keySet() ) {
    		c2g__codaPeriod__c somePeriod = somePeriods.get(someId);
            String key = somePeriod.c2g__PeriodNumber__c;
		    periodLookup.put(Integer.valueOf(key.right(2)), somePeriod);
		}
        
        // Create a variety of personnel cost records, one for each type and period.
        List<Personnel_Cost_Record__c> compensation = createBaseSalary(positions, batch, periodLookup);
        List<Personnel_Cost_Record__c> fourOhThreeBee = create403b(positions, batch, periodLookup); 
        List<Personnel_Cost_Record__c> emDeeVee = createMedicalDentalVision(positions, batch, periodLookup);
        List<Personnel_Cost_Record__c> lifeAndAdd = createLifeAndAdd(positions, batch, periodLookup);   
        List<Personnel_Cost_Record__c> longTermDisability = createLongTermDisability(positions, batch, periodLookup);           
        List<Personnel_Cost_Record__c> fica = createFica(positions, batch, periodLookup);   
        List<Personnel_Cost_Record__c> futa = createFuta(positions, batch, periodLookup);           
		List<Personnel_Cost_Record__c> suta = createSuta(positions, batch, periodLookup);   
        List<Personnel_Cost_Record__c> medicare = createMedicare(positions, batch, periodLookup);   
        List<Personnel_Cost_Record__c> pfml = createPfml(positions, batch, periodLookup);           
        List<Personnel_Cost_Record__c> bonus = createBonus(positions, batch, periodLookup);  

        List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
        forInsert.addAll(compensation);
        forInsert.addAll(fourOhThreeBee);
        forInsert.addAll(fica);
        forInsert.addAll(medicare);
        forInsert.addAll(futa);
        forInsert.addAll(suta);
        forInsert.addAll(pfml);
        forInsert.addAll(emDeeVee);        
        forInsert.addAll(lifeAndAdd);        
        forInsert.addAll(longTermDisability);                
        forInsert.addAll(bonus);
        insert forInsert;
    }
    
    private List<Personnel_Cost_Record__c> createBaseSalary(List<Budget_Position__c> positions, 
		Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
        // This routine is fairly straightforward. Loop for 12 months, applying a targeted increase if 
        // the review date is current or in the past, creating base salary records.
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
        for(Budget_Position__c position : positions) {
            
            Integer loopCount = getFiscalMonth(position.Hire_Date__c, batch.Year__c);
            Integer increaseMonth = getFiscalMonth(position.Review_Date__c, batch.Year__c);
            while(loopCount <= 12) {
                Double salary = 0.00;
                if( loopCount <= increaseMonth ) { 
                	salary = position.Adjusted_Salary__c/12;
                } else {
					salary = position.Adjusted_Salary__c/12 + 
                        (position.Adjusted_Salary__c * (position.Targeted_Increase__c/100))/12;
                }
                Personnel_Cost_Record__c salaryPeriod = 
                	new Personnel_Cost_Record__c(Type__c = 'Base Salary',  Amount__c = salary,
                    		Personnel_Budget_Batch__c = batch.Id, Budget_Position__c = position.Id,
                        	Period__c = periodLookup.get(loopCount).Id);
                forInsert.add(salaryPeriod);
                loopCount += 1;
            }
        }
        return forInsert;
    }

    private List<Personnel_Cost_Record__c> create403b(List<Budget_Position__c> positions, 
    	Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
                                                             
        for(Budget_Position__c position : positions) {
            
            Double fourOhThreeTabulation = 0.00;
            boolean endRoutine1 = false;
            Integer loop1Count = 1;
            
            // 403b limits must be calculated across two calendar years. This first loop below represents the first 
            // calendar year. It loops for 12 months, but only data for the last 6 months (Jul-Dec) are inserted.
            // Once the limit is reached, the routine is ended.
            while(loop1Count <= 12 ) {
                //System.debug(getCalendarMonthYear1(position.Hire_Date__c, true, batch.Year__c));
                if(loop1Count >= getCalendarMonthYear1(position.Hire_Date__c, true, false, batch.Year__c)) {
                    System.debug('--------');
                    System.debug(loop1Count);
                    Double period403b;
                    Double contrib = 0.00;
                    Double save = 0.00;
                
		            Integer increaseMonth = getCalendarMonthYear1(position.Review_Date__c, false, false, batch.Year__c);
					System.debug('Increase month: ' + increaseMonth);
                    if(increaseMonth >= 7 && increaseMonth <= 12 && loop1Count > increaseMonth) {
                        System.debug('Reflecting increased salary.');
                        contrib = (position.Increased_Salary__c / 12) * (batch.X403b__c/100);
                        save = (position.Increased_Salary__c / 12);
                        fourOhThreeTabulation += save;
                    } else {
                        Integer adjustmentMonth = getCalendarMonthYear1(position.Review_Date__c.addYears(-1), false, true, batch.Year__c);
                        System.debug('Adjustment month: ' + adjustmentMonth);
                        if(loop1Count > adjustmentMonth) {
                                System.debug('Reflecting adjusted salary.');
    	                        contrib = (position.Adjusted_Salary__c / 12 * (batch.X403b__c/100));
        	                    save = (position.Adjusted_Salary__c / 12);
            	                System.debug('Contrib: ' + contrib);
                	            System.debug('Save: ' + save);               
                    	        fourOhThreeTabulation += save;
                        	    System.debug(fourOhThreeTabulation);                                
                        }
                        else {
							System.debug('Reflecting base salary.');
                            contrib = (position.Annual_Salary__c / 12 * (batch.X403b__c/100));
                            save = (position.Annual_Salary__c / 12);
                            System.debug('Contrib: ' + contrib);
                            System.debug('Save: ' + save);            
                            fourOhThreeTabulation += save;
                            System.debug(fourOhThreeTabulation);
                        }
                    }
                
                    // If we haven't hit the max, no problem. Otherwise, we re-tabulate the contribution 
                    // based on the difference between the max and the previous total.
                    if(fourOhThreeTabulation <= batch.X403b_Max__c) {   
                        period403b = contrib;
                    } else {
                        period403b = ((batch.X403b_Max__c - (fourOhThreeTabulation - save)) * (batch.X403b__c/100));
                        endRoutine1 = true;
                    }
                
                    // Only insert if the data is for July-December.
                    if(loop1Count >= 7 && loop1Count <= 12 && position.Benefits_Eligible__c == true) {
                        System.debug('Keeper.');
                        Personnel_Cost_Record__c fourOhThreeBPeriod = 
                                new Personnel_Cost_Record__c(Type__c = '403b', Amount__c = period403b + position.Employer_457b_Contributions__c, 
                                    Personnel_Budget_Batch__c = batch.Id,  Budget_Position__c = position.Id, 
                                    Period__c = periodLookup.get(loop1Count-6).Id);
                        forInsert.add(fourOhThreeBPeriod);  
                    }
                }
                    
                loop1Count+= 1;
                if( endRoutine1 == true ) break;
            }
            
            // 403b limits must be calculated across two calendar years. The second loop below represents the second 
            // calendar year. It loops for only 6 months (Jan-June). Once the limit is reached, the routine is ended.            
	        fourOhThreeTabulation = 0.00;
            boolean endRoutine2 = false;            
            Integer loop2Count = 1;
            Integer increaseMonth = getCalendarMonthYear2(position.Review_Date__c, false, batch.Year__c);            
            
            while(loop2Count <= 6) {
                System.debug(getCalendarMonthYear2(position.Hire_Date__c, true, batch.Year__c));
                if(loop2Count >= getCalendarMonthYear2(position.Hire_Date__c, true, batch.Year__c)) { 
                    Double period403b;
                    Double contrib = 0.00;
                    Double save = 0.00;            
                    if(increaseMonth < 7 && loop2Count > increaseMonth) {
                        contrib = (position.Increased_Salary__c / 12) * (batch.X403b__c/100);
                        save = (position.Increased_Salary__c / 12);
                        fourOhThreeTabulation += save;
                    
                    } else {
                        contrib = (position.Adjusted_Salary__c/12 * (batch.X403b__c/100));
                        save = (position.Adjusted_Salary__c/12);
                        fourOhThreeTabulation += save;
                    }                
                
                    // If we haven't hit the max, no problem. Otherwise, we re-tabulate the contribution 
                    // based on the difference between the max and the previous total.                
                    if(fourOhThreeTabulation <= batch.X403b_Max__c) {   
                        period403b = contrib;
                    } else {
                        period403b = ((batch.X403b_Max__c - (fourOhThreeTabulation - save)) * (batch.X403b__c/100));
                        endRoutine2 = true;
                    }
                
                    Personnel_Cost_Record__c fourOhThreeBPeriod = 
                        new Personnel_Cost_Record__c(Type__c = '403b', 
                                                     Amount__c = period403b + position.Employer_457b_Contributions__c, 
                                                     Personnel_Budget_Batch__c = batch.Id, 
                                                     Budget_Position__c = position.Id, Period__c = periodLookup.get(loop2Count+6).Id);
                    if( position.Benefits_Eligible__c == true ) {
	                    forInsert.add(fourOhThreeBPeriod);  
                    }
                }
                loop2Count+= 1;
                if( endRoutine2 == true ) break;
            }
        }
        return forInsert;
    }        
    
    private List<Personnel_Cost_Record__c> createFica(List<Budget_Position__c> positions, 
                                                         Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
                                                             
        for(Budget_Position__c position : positions) {
            
            Double ficaTabulation = 0.00;
            boolean endRoutine1 = false;
            Integer loop1Count = 1;

            // FICA limits must be calculated across two calendar years. This first loop below represents the first 
            // calendar year. It loops for 12 months, but only data for the last 6 months (Jul-Dec) are inserted.
            // Once the limit is reached, the routine is ended.            
            while(loop1Count <= 12) {
                if(loop1Count >= getCalendarMonthYear1(position.Hire_Date__c, false, false, batch.Year__c)) {                
                    Double periodFica;
		            Integer increaseMonth = getCalendarMonthYear1(position.Review_Date__c, false, false, batch.Year__c);
    
                    if(increaseMonth >= 7 && increaseMonth <= 12 && loop1Count > increaseMonth) {                
                        ficaTabulation += (position.Increased_Salary__c/12);
                        if(ficaTabulation <= batch.FICA_Max__c) {   
                            periodFica = (position.Increased_Salary__c/12) * (batch.FICA__c/100);  
                        } else {
                            periodFica = (batch.FICA_Max__c - (ficaTabulation - position.Increased_Salary__c/12)) * (batch.FICA__c/100);
                            endRoutine1 = true;
                        }
                    }
                    else {
                        ficaTabulation += (position.Adjusted_Salary__c/12);
                        if(ficaTabulation <= batch.FICA_Max__c) {   
                            periodFica = (position.Adjusted_Salary__c/12) * (batch.FICA__c/100);  
                        } else {
                            periodFica = (batch.FICA_Max__c - (ficaTabulation - position.Adjusted_Salary__c/12)) * (batch.FICA__c/100);
                            endRoutine1 = true;
                        }                    
                    }
                    
                    if(loop1Count >= 7 && loop1Count <= 12) {
                        Personnel_Cost_Record__c ficaPeriod = 
                                new Personnel_Cost_Record__c(Type__c = 'FICA', 
                                    Amount__c = periodFica, Personnel_Budget_Batch__c = batch.Id, 
                                    Budget_Position__c = position.Id, Period__c = periodLookup.get(loop1Count-6).Id);
                        forInsert.add(ficaPeriod);  
                    }
                }
                loop1Count+= 1;
                if( endRoutine1 == true ) break;
            }
            
	        ficaTabulation = 0.00;
            boolean endRoutine2 = false;            
            Integer loop2Count = 1;
            
            // FICA limits must be calculated across two calendar years. The second loop below represents the second 
            // calendar year. It loops for only 6 months (Jan-June). Once the limit is reached, the routine is ended.             
            while(loop2Count <= 6) {
                if(loop2Count >= getCalendarMonthYear2(position.Hire_Date__c, false, batch.Year__c)) {                 
                    Double periodFica;
                    Integer increaseMonth = getCalendarMonthYear2(position.Review_Date__c, false, batch.Year__c);
    
                    if(increaseMonth < 7 && loop2Count > increaseMonth) {                
                        ficaTabulation += (position.Increased_Salary__c/12);
                        if(ficaTabulation <= batch.FICA_Max__c) {   
                            periodFica = (position.Increased_Salary__c/12) * (batch.FICA__c/100);  
                        } else {
                            periodFica = (batch.FICA_Max__c - (ficaTabulation - position.Increased_Salary__c/12)) * (batch.FICA__c/100); 
                            endRoutine2 = true;
                        }
                    } else {
                        ficaTabulation += (position.Adjusted_Salary__c/12);
                        if(ficaTabulation <= batch.FICA_Max__c) {   
                            periodFica = (position.Adjusted_Salary__c/12) * (batch.FICA__c/100);  
                        } else {
                            periodFica = (batch.FICA_Max__c - (ficaTabulation - position.Adjusted_Salary__c/12)) * (batch.FICA__c/100); 
                            endRoutine2 = true;
                        }
                    }
                    
                    Personnel_Cost_Record__c ficaPeriod = 
                        new Personnel_Cost_Record__c(Type__c = 'FICA',  Amount__c = periodFica, 
                                                     Personnel_Budget_Batch__c = batch.Id, 
                                                     Budget_Position__c = position.Id, 
                                                     Period__c = periodLookup.get(loop2Count+6).Id);
                    forInsert.add(ficaPeriod);
                }
                loop2Count+= 1;
                if( endRoutine2 == true ) break;
            }
        }
        return forInsert;
    }     
    
    private List<Personnel_Cost_Record__c> createPfml(List<Budget_Position__c> positions, 
                                                         Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
                                                 
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
        for(Budget_Position__c position : positions) {
            
            Integer increaseMonth = getFiscalMonth(position.Review_Date__c, batch.Year__c);
            Integer bonusMonth = 99;
            if( position.Bonus__c != null && position.Bonus__c <> 0 ) {
                bonusMonth = getFiscalMonth(position.Bonus_Date__c, batch.Year__c);
            }              
            
            Integer loopCount = getFiscalMonth(position.Hire_Date__c, batch.Year__c);
            while(loopCount <= 12) {
                Double pfmlAmount = 0.00;
                if( loopCount <= increaseMonth) { 
                    if( loopCount == bonusMonth ) {
                        pfmlAmount = ((position.Adjusted_Salary__c/12) + position.Bonus__c) * (batch.PFML__c/100);
                    }
                    else {
						pfmlAmount = (position.Adjusted_Salary__c/12) * (batch.PFML__c/100);
                    }

                } else {
                    if( loopCount == bonusMonth ) {
                        pfmlAmount = ((position.Increased_Salary__c/12) + position.Bonus__c) * (batch.PFML__c/100);
                    }
                    else {
	                    pfmlAmount = (position.Increased_Salary__c/12) * (batch.PFML__c/100);
                    }
                }   
                
                Personnel_Cost_Record__c salaryPeriod = 
                	new Personnel_Cost_Record__c(Type__c = 'PFML', Amount__c = pfmlAmount, 
                            Personnel_Budget_Batch__c = batch.Id, 
                            Budget_Position__c = position.Id, Period__c = periodLookup.get(loopCount).Id);
                forInsert.add(salaryPeriod);
                loopCount += 1;
            }
        }
        return forInsert;
    }         
    
    private List<Personnel_Cost_Record__c> createMedicare(List<Budget_Position__c> positions, 
                                                         Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
        for(Budget_Position__c position : positions) {
            System.debug('Calculating medicare for ' + position.Employee_Name__c);
            Integer increaseMonth = getFiscalMonth(position.Review_Date__c, batch.Year__c);
            Integer bonusMonth = 99;
            if( position.Bonus__c != null && position.Bonus__c <> 0 ) {
            	bonusMonth = getFiscalMonth(position.Bonus_Date__c, batch.Year__c);
            }
            
            Integer loopCount = getFiscalMonth(position.Hire_Date__c, batch.Year__c);
            
            // Medicare is uncapped. We calculate our result being sensitive to the annual increase. We also need to factor in a 
            // potential bonus which are marked for a particular month.
            while(loopCount <= 12) {
                Double medicareAmount = 0.00;
                if( loopCount <= increaseMonth) { 
                    if( loopCount == bonusMonth) {
						medicareAmount = ((position.Adjusted_Salary__c/12) + position.Bonus__c) * (batch.Medicare__c/100);
                    } else { 
                    	medicareAmount = (position.Adjusted_Salary__c/12) * (batch.Medicare__c/100);
                    }
                } else {
                    if ( loopCount == bonusMonth) {
						medicareAmount = ((position.Increased_Salary__c/12) + position.Bonus__c) * (batch.Medicare__c/100);                        
                    }
                    else {
	                    medicareAmount = (position.Increased_Salary__c/12) * (batch.Medicare__c/100);                        
                    }
                }                
                                
                Personnel_Cost_Record__c salaryPeriod = 
                	new Personnel_Cost_Record__c(Type__c = 'Medicare', Amount__c = medicareAmount,
                    		Personnel_Budget_Batch__c = batch.Id,  Budget_Position__c = position.Id,
                        	Period__c = periodLookup.get(loopCount).Id);
                forInsert.add(salaryPeriod);
                loopCount += 1;
            }
        }
        return forInsert;
    }   
    
    private List<Personnel_Cost_Record__c> createFuta(List<Budget_Position__c> positions, 
                                                         Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
                                                             
        for(Budget_Position__c position : positions) {
            
            Double futaTabulation = 0.00;
            boolean endRoutine1 = false;
            Integer loop1Count = 1;

            // comment here          
            while(loop1Count <= 12) {           

                Double periodFuta;     
                if(loop1Count >= getCalendarMonthYear1(position.Hire_Date__c, false, false, batch.Year__c)) {                

                    futaTabulation += (position.Adjusted_Salary__c/12);
                    if(futaTabulation <= batch.FUTA_Max__c) {   
                        periodFuta = (position.Adjusted_Salary__c/12) * (batch.FUTA__c/100);  
                    } else {
                        periodFuta = (batch.FUTA_Max__c - (futaTabulation - position.Adjusted_Salary__c/12)) * (batch.FUTA__c/100);
                        endRoutine1 = true;
                    }           
                    
                    if(loop1Count >= 7 && loop1Count <= 12) {
                        Personnel_Cost_Record__c futaPeriod = 
                            new Personnel_Cost_Record__c(Type__c = 'FUTA', 
                                                         Amount__c = periodFuta, Personnel_Budget_Batch__c = batch.Id, 
                                                         Budget_Position__c = position.Id, Period__c = periodLookup.get(loop1Count-6).Id);
                        forInsert.add(futaPeriod);  
                    }
                }
                loop1Count+= 1;
                if( endRoutine1 == true ) break;
            }
            
	        futaTabulation = 0.00;
            boolean endRoutine2 = false;            
            Integer loop2Count = 1;
            
            // comment here           
            while(loop2Count <= 6) {
                if(loop2Count >= getCalendarMonthYear2(position.Hire_Date__c, false, batch.Year__c)) {                 
                    Double periodFuta;
    
                    futaTabulation += (position.Adjusted_Salary__c/12);
                    if(futaTabulation <= batch.FUTA_Max__c) {   
                        periodFuta = (position.Adjusted_Salary__c/12) * (batch.FUTA__c/100);  
                    } else {
                        periodFuta = (batch.FUTA_Max__c - (futaTabulation - position.Adjusted_Salary__c/12)) * (batch.FUTA__c/100); 
                        endRoutine2 = true;
                    }
                    
                    Personnel_Cost_Record__c futaPeriod = 
                        new Personnel_Cost_Record__c(Type__c = 'FUTA',  Amount__c = periodFuta, 
                                                     Personnel_Budget_Batch__c = batch.Id, 
                                                     Budget_Position__c = position.Id, 
                                                     Period__c = periodLookup.get(loop2Count+6).Id);
                    forInsert.add(futaPeriod);
                }
                loop2Count+= 1;
                if( endRoutine2 == true ) break;
            }
        }
        return forInsert;
    }         

    private List<Personnel_Cost_Record__c> createSuta(List<Budget_Position__c> positions, 
    	Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
                                                             
        for(Budget_Position__c position : positions) {
            
            Double sutaTabulation = 0.00;
            boolean endRoutine1 = false;
            Integer loop1Count = 1;

            // comment here          
            while(loop1Count <= 12) {           

                Double periodSuta;     
                if(loop1Count >= getCalendarMonthYear1(position.Hire_Date__c, false, false, batch.Year__c)) {                

                    sutaTabulation += (position.Adjusted_Salary__c/12);
                    if(sutaTabulation <= batch.SUTA_Max__c) {   
                        periodSuta = (position.Adjusted_Salary__c/12) * (batch.SUTA__c/100);  
                    } else {
                        periodSuta = (batch.SUTA_Max__c - (sutaTabulation - position.Adjusted_Salary__c/12)) * (batch.SUTA__c/100);
                        endRoutine1 = true;
                    }           
                    
                    if(loop1Count >= 7 && loop1Count <= 12) {
                        Personnel_Cost_Record__c sutaPeriod = 
                            new Personnel_Cost_Record__c(Type__c = 'SUTA', 
                                                         Amount__c = periodSuta, Personnel_Budget_Batch__c = batch.Id, 
                                                         Budget_Position__c = position.Id, Period__c = periodLookup.get(loop1Count-6).Id);
                        forInsert.add(sutaPeriod);  
                    }
                }
                loop1Count+= 1;
                if( endRoutine1 == true ) break;
            }
            
	        sutaTabulation = 0.00;
            boolean endRoutine2 = false;            
            Integer loop2Count = 1;
            
            // comment here           
            while(loop2Count <= 6) {
                if(loop2Count >= getCalendarMonthYear2(position.Hire_Date__c, false, batch.Year__c)) {                 
                    Double periodSuta;
    
                    sutaTabulation += (position.Adjusted_Salary__c/12);
                    if(sutaTabulation <= batch.SUTA_Max__c) {   
                        periodSuta = (position.Adjusted_Salary__c/12) * (batch.SUTA__c/100);  
                    } else {
                        periodSuta = (batch.SUTA_Max__c - (sutaTabulation - position.Adjusted_Salary__c/12)) * (batch.SUTA__c/100); 
                        endRoutine2 = true;
                    }
                    
                    Personnel_Cost_Record__c sutaPeriod = 
                        new Personnel_Cost_Record__c(Type__c = 'SUTA',  Amount__c = periodSuta, 
                                                     Personnel_Budget_Batch__c = batch.Id, 
                                                     Budget_Position__c = position.Id, 
                                                     Period__c = periodLookup.get(loop2Count+6).Id);
                    forInsert.add(sutaPeriod);
                }
                loop2Count+= 1;
                if( endRoutine2 == true ) break;
            }
        }
        return forInsert;
    }             
    
    private List<Personnel_Cost_Record__c> createMedicalDentalVision(List<Budget_Position__c> positions, 
    	Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
        for(Budget_Position__c position : positions) {
            
            Integer loopCount = getFiscalMonth(position.Hire_Date__c, batch.Year__c);            
            while(loopCount <= 12) {
                Personnel_Cost_Record__c salaryPeriod = 
                	new Personnel_Cost_Record__c(Type__c = 'Medical, Dental, Vision', 
                        	Amount__c = position.Medical_Dental_and_Vision__c,
                    		Personnel_Budget_Batch__c = batch.Id, Budget_Position__c = position.Id,
                        	Period__c = periodLookup.get(loopCount).Id);
                forInsert.add(salaryPeriod);
                loopCount += 1;
            }
        }
        return forInsert;
    }        
    
    private List<Personnel_Cost_Record__c> createLifeAndAdd(List<Budget_Position__c> positions, 
                                                         Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();

        for(Budget_Position__c position : positions) {

            Integer increaseMonth = getFiscalMonth(position.Review_Date__c, batch.Year__c);                                                             
            Double lifeAndADeeAndDeeAmount = 0.00;
            Integer loopCount = getFiscalMonth(position.Hire_Date__c, batch.Year__c);            

            while(loopCount <= 12) {
                // Basic Life AD&D. Handle capped amount - 250k.
                if( position.Adjusted_Salary__c > batch.Basic_Life_AD_D_Max__c ) {
                    lifeAndADeeAndDeeAmount = (((batch.Basic_Life_AD_D_Max__c * 2) / 1000) * .149);
                    
                } else if (loopCount <= increaseMonth) {
					lifeAndADeeAndDeeAmount = (((position.Adjusted_Salary__c * 2) / 1000) * .149);
                }
                else {
                    lifeAndADeeAndDeeAmount = (((position.Increased_Salary__c * 2) / 1000) * .149);               
                }
                
                Personnel_Cost_Record__c salaryPeriod = 
                	new Personnel_Cost_Record__c(Type__c = 'Life and AD&D', 
                        	Amount__c = lifeAndADeeAndDeeAmount,
                    		Personnel_Budget_Batch__c = batch.Id, Budget_Position__c = position.Id,
                        	Period__c = periodLookup.get(loopCount).Id);
                if( position.Benefits_Eligible__c == true ) {
	                forInsert.add(salaryPeriod);
                }
                loopCount += 1;
            }
        }
        return forInsert;
    }
    
    private List<Personnel_Cost_Record__c> createLongTermDisability(List<Budget_Position__c> positions, 
                                                         Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();

        for(Budget_Position__c position : positions) {

            Integer increaseMonth = getFiscalMonth(position.Review_Date__c, batch.Year__c);
            Double disabilityAmount = 0.00;
            Double executiveDisability = position.Executive_Disability_Amount__c;
            Integer loopCount = getFiscalMonth(position.Hire_Date__c, batch.Year__c);            

            while(loopCount <= 12) {

                // Long Term Disability. Handle capped amount - 350k.
                if( position.Adjusted_Salary__c > batch.Long_Term_Disability_Max__c ) {
					disabilityAmount = (((batch.Long_Term_Disability_Max__c/12)/100) * .310);
                    
                } else if (loopCount <= increaseMonth) {
                    disabilityAmount = (((position.Adjusted_Salary__c/12)/100) * .310);
                }
                else {
                    disabilityAmount = (((position.Increased_Salary__c/12)/100) * .310);                    
                }
                
                Personnel_Cost_Record__c salaryPeriod = 
                	new Personnel_Cost_Record__c(Type__c = 'Long-Term Disability', 
                        	Amount__c = disabilityAmount + executiveDisability,
                    		Personnel_Budget_Batch__c = batch.Id, Budget_Position__c = position.Id,
                        	Period__c = periodLookup.get(loopCount).Id);
                if( position.Benefits_Eligible__c == true ) {
	                forInsert.add(salaryPeriod);
                }
                loopCount += 1;
            }
        }
        return forInsert;
    }    

    private List<Personnel_Cost_Record__c> createBonus(List<Budget_Position__c> positions, 
                                                         Personnel_Budget_Batch__c batch, Map<Integer, c2g__codaPeriod__c> periodLookup) {
        
		List<Personnel_Cost_Record__c> forInsert = new List<Personnel_Cost_Record__c>();
        for(Budget_Position__c position : positions) {
            if(position.Bonus_Date__c != null && position.Bonus__c != null && position.Bonus__c > 0) {
                Integer bonusMonth = getFiscalMonth(position.Bonus_Date__c, batch.Year__c);
                Integer loopCount = 1;
                while(loopCount <= 12) {
                    if(loopCount == bonusMonth) {
                        Personnel_Cost_Record__c salaryPeriod = 
                            new Personnel_Cost_Record__c(Type__c = 'Bonus', 
                                Amount__c = position.Bonus__c,
                                Personnel_Budget_Batch__c = batch.Id,  Budget_Position__c = position.Id,
                                Period__c = periodLookup.get(loopCount).Id);
                        forInsert.add(salaryPeriod);
                    }
                    loopCount += 1;
                }
            }
        }
        return forInsert;
    }    

    private static Integer getFiscalMonth(Date someDate, String batchYear) {
        
        // i.e. 2023-07-01
        if(someDate < Date.newInstance(Integer.valueOf(batchYear)-1,7,1)) {
            return 1;
	    } 
        // i.e. 2024-06-30
        else if (someDate > Date.newInstance(Integer.valueOf(batchYear),6,30)) {
			return 99;
        }
       
        Integer switchMonth = someDate.month();
        switch on switchMonth {
            when 1 { return 7; }
            when 2 { return 8; }
            when 3 { return 9; }
            when 4 { return 10; }
            when 5 { return 11; }
            when 6 { return 12; }
            when 7 { return 1; }
            when 8 { return 2; }
            when 9 { return 3; }
            when 10 { return 4; }
            when 11 { return 5; }
            when 12 { return 6; }            
        }
        return 99;
    }     
    
    private static Integer getCalendarMonthYear1(Date someDate, boolean isFor403bStart, boolean isFor403bAdjustment, String batchYear) {
        
        // i.e. less than 2023-07-01, outside the typical scope of concern.
        if(someDate < Date.newInstance(Integer.valueOf(batchYear)-1,7,1)) {
            // Special case - if we're looking for 403b start date, we need to be careful to not start 
            // 403b until 6 months after start date - relevant if they started in the winter/spring of the 
            // previous year.
            if( isFor403bStart == true && someDate >= Date.newInstance(Integer.valueOf(batchYear)-1,1,1)) {
				return someDate.month() + 6;
            }
            if( isFor403bAdjustment == true && someDate >= Date.newInstance(Integer.valueOf(batchYear)-1,1,1)) {
            	return someDate.month();
            }
            else {
	            return 0;                
            }
        } 
        // i.e. greater than 2023-12-31, outside the typical scope of concern.
    	else if (someDate > Date.newInstance(Integer.valueOf(batchYear)-1,12,31)) {
            return 99;
        }
    	else {
            // We delay the start of 403b until 6 months from hire date.
            if( isFor403bStart == true ) { 
                // Any year 1 hires wouldn't receive 403b contribs in the scope of a 'Year 1' sub-routine, 
                // so returning 99 effectively removes the generation of 403b numbers for year 1.
                return 99;
            }
            else { 
    	    	return someDate.month();
            }
        }
    }   
    
    /**
     * This method is doing a lot. (too much?) 
     * Generally, it will return an integer representing a hire date or review date 
     * for the second calendar year within a particlar calendar year. It does some evaluation to determine if either of 
     * those dates fall outside the range of concern ('scope').
     * For 403b related purposes, the code adds 6 months to the hire date to delay the impact of 403b.
    */
    private static Integer getCalendarMonthYear2(Date someDate, boolean isFor403b, String batchYear) {
        
        // i.e. between 2023-6-30 and 2024-01-01
        if( someDate > Date.newInstance(Integer.valueOf(batchYear)-1,6,30) && someDate < Date.newInstance(Integer.valueOf(batchYear),1,1) ) {
            if(isFor403b == true) {
        		// need special logic here. Ordinarily we wouldn't care about a date outside the scope of 
        		// calendar year 2, but in this case we need to calculate a 6 month offset for 403b for employees with a hire date
        		// in the first half of the fiscal year.
				return someDate.addMonths(6).month();
            } else {
	            // Outside the scope of year 2.
                return 0;                
            }
    	}
        // i.e. greater than 2024-06-30
        else if (someDate > Date.newInstance(Integer.valueOf(batchYear),6,30)) {
            // Outside the scope of year 2.
			return 99;
        }
        // Prior to the batch fiscal year start.
        else if( someDate < Date.newInstance(Integer.valueOf(batchYear)-1,6,30) ) {
	   	    return 0;
        }
        else if( isFor403b == true) {
           	return someDate.addMonths(6).month();
        }
        return someDate.month();
    }
    
    global void finish(Database.BatchableContext bc) { 
        /**
    	List<Personnel_Budget_Batch__c> batches = [SELECT Id, Staged__c FROM Personnel_Budget_Batch__c WHERE Id = :batchId];
        Personnel_Budget_Batch__c batch = batches.get(1);
        batch.Staged__c = true;
        update batch;
		*/
    } 
}