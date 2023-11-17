@isTest(SeeAllData=true)
public class FiscalYearFinderTest {
    
	static testMethod void testGetFiscalYear() {
        Integer result2 = FiscalYearFinder.getFiscalYear(Date.newInstance(2019, 10, 01));
        System.assertEquals(result2, 2020);
        Integer result5 = FiscalYearFinder.getFiscalYear(Date.newInstance(2020, 6, 01));       
        System.assertEquals(result5, 2020); 
        Integer result4 = FiscalYearFinder.getFiscalYear(Date.newInstance(2021, 10, 01));
        System.assertEquals(result4, 2022);         
        Integer result1 = FiscalYearFinder.getFiscalYear(Date.newInstance(2022, 3, 01));
        System.assertEquals(result1, 2022);
        Integer result3 = FiscalYearFinder.getFiscalYear(Date.newInstance(2023, 10, 01));
        System.assertEquals(result3, 2024);
    }
    
    static testMethod void testFutureFiscalYear() {
        boolean result1 = FiscalYearFinder.isFutureFiscalYear(Date.today());
        System.assertEquals(false, result1);
       	boolean result2 = FiscalYearFinder.isFutureFiscalYear(Date.newInstance(2025,04,12));
		System.assertEquals(true, result2);        
       	boolean result3 = FiscalYearFinder.isFutureFiscalYear(Date.newInstance(2020,04,12));
		System.assertEquals(false, result3);
    }
    
    static testMethod void testFutureFiscalQuarter() {
        boolean result = FiscalYearFinder.isFutureFiscalQuarter(Date.today(), Date.newInstance(2019,01,01));
        System.assertEquals(false, result);
        boolean result2 = FiscalYearFinder.isFutureFiscalQuarter(Date.today(), Date.newInstance(2028,01,01));
        System.assertEquals(true, result2);
        boolean result3 = FiscalYearFinder.isFutureFiscalQuarter(Date.today(), Date.newInstance(2021,06,01));
        System.assertEquals(false, result3);
        boolean result4 = FiscalYearFinder.isFutureFiscalQuarter(Date.today(), Date.newInstance(2025,06,01));
        System.assertEquals(true, result4);
        
        boolean result5 = FiscalYearFinder.isFutureFiscalQuarter(Date.newInstance(2023,08,01), Date.newInstance(2024,01,01));
        System.assertEquals(true, result5);
        boolean result6 = FiscalYearFinder.isFutureFiscalQuarter(Date.newInstance(2023,10,01), Date.newInstance(2024,01,01));
        System.assertEquals(true, result6);
        boolean result7 = FiscalYearFinder.isFutureFiscalQuarter(Date.newInstance(2024,01,01), Date.newInstance(2024,02,01));
        System.assertEquals(false, result7);
        boolean result8 = FiscalYearFinder.isFutureFiscalQuarter(Date.newInstance(2024,01,01), Date.newInstance(2024,06,01));
        System.assertEquals(true, result8); 
        boolean result9 = FiscalYearFinder.isFutureFiscalQuarter(Date.newInstance(2024,10,01), Date.newInstance(2024,08,01));
        System.assertEquals(false, result9);  
        boolean result10 = FiscalYearFinder.isFutureFiscalQuarter(Date.newInstance(2024,10,01), Date.newInstance(2024,11,01));
        System.assertEquals(false, result10);          
    }
    
    static testMethod void testGetFiscalYearStart() {
        Date result1 = FiscalYearFinder.getFiscalYearStart(2022);
        System.assertEquals(result1, Date.newInstance(2022,7,01));
        Date result2 = FiscalYearFinder.getFiscalYearStart(2023);
        System.assertEquals(result2, Date.newInstance(2023,7,01));
        Date result3 = FiscalYearFinder.getFiscalYearStart(2024);
        System.assertEquals(result3, Date.newInstance(2024,7,01));        
    }
    
    static testMethod void testGetFiscalYearEnd() {
        Date result1 = FiscalYearFinder.getFiscalYearEnd(2022);
        System.assertEquals(result1, Date.newInstance(2023,6,30));
        Date result2 = FiscalYearFinder.getFiscalYearEnd(2023);
        System.assertEquals(result2, Date.newInstance(2024,6,30));
        Date result3 = FiscalYearFinder.getFiscalYearEnd(2024);
        System.assertEquals(result3, Date.newInstance(2025,6,30));        
    }
    
    static testMethod void testCurrentFiscalYear() {
        Integer result = FiscalYearFinder.currentFiscalYear();
        System.assertEquals(result, 2024);
    }
}