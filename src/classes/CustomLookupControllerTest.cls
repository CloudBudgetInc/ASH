@IsTest
public with sharing class CustomLookupControllerTest {
	@IsTest
	public static void testCustomLookupController() {
		System.assertEquals(0, CustomLookupController.fetchLookUpValues('', 'Account').size());
	}
}