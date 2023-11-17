@isTest
public with sharing class CTNMapControllerTest {
	@isTest(SeeAllData=true)
	public static void testCTNMapController() {
		System.assert(CTNMapController.getAccounts().size() == 0);
		System.assert(CTNMapController.getCTUs().size() == 0);
	}
}