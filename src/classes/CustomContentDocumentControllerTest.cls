@isTest
public with sharing class CustomContentDocumentControllerTest {
  @isTest
	public static void testCustomContentDocumentController () {
		System.assert(CustomContentDocumentController.getContactId() == null);
		System.assert(CustomContentDocumentController.getContentDocuments() == null);
		System.assert(CustomContentDocumentController.getContentVersions() == null);
	}
}