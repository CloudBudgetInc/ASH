public class FiscalYearFinder {
    
    public static boolean isFutureFiscalYear(Date someDate) {
        Date today = System.today();
        if(getFiscalYear(someDate) <= getFiscalYear(today)) {
            return false;
        }
        return true;
    }
    
    public static Integer getFiscalYear(Date someDate) {
        
        if(someDate.month() > 0 && someDate.month() < 7) {
            return someDate.year();
        }
        else {
            return someDate.year() + 1;
        }
    }
    
    public static boolean isFutureFiscalQuarter(Date someDate) {
 		return isFutureFiscalQuarter(Date.today(), someDate);
    }
    
    public static boolean isFutureFiscalQuarter(Date today, Date someDate) {
        
        // If it's in a previous FY, it's definitely not in a future fiscal quarter...
        if(getFiscalYear(someDate) < getFiscalYear(today)) {
            return false;
        }
        
        // If it's in a future FY, it's definitely in a future fiscal quarter...
        if(getFiscalYear(someDate) > getFiscalYear(today)) {
            return true;
        }
        
        return getFiscalQuarter(today.month()) < getFiscalQuarter(someDate.month());
        
        /**
        // Q1
        if(today.month() >= 1 && today.month() <=3 && someDate.month() > 3) { 
        	return true;
        } // Q2
        if(today.month() >= 4 && today.month() <=6 && someDate.month() > 6) { 
        	return true;
        } // Q3
        if(today.month() >= 7 && today.month() <=9 && someDate.month() > 9) { 
        	return true;
        } // Q4. I question if we need this clause.
        if(today.month() >= 10 && today.month() <= 12 && someDate.month() > 12) {
        	return true;
        }
		*/
    }

	public static Integer getFiscalQuarter(Integer month) {
        switch on month {
            when 1 { return 3; } // january
            when 2 { return 3; } // feb
            when 3 { return 3; }
            when 4 { return 4; } // april
            when 5 { return 4; }
            when 6 { return 4; }
            when 7 { return 1; } // july!
            when 8 { return 1; }
            when 9 { return 1; }
            when 10 { return 2; } // october
            when 11 { return 2; }
            when 12 { return 2; }
        }
        return 0;
    }
    
    public static Date getFiscalYearStart(Integer year) {
		return Date.newInstance(year,07,01);
    }
    
    public static Date getFiscalYearEnd(Integer year) {
		return Date.newInstance(year+1,06,30);
    }

    public static Integer currentFiscalYear() {

        if(System.today().month() > 0 && System.today().month() < 7) {
            return System.today().year();
        }
        else {
            return System.today().year() + 1;
        }
    }
}