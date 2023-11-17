@isTest(SeeAllData=true)
public with sharing class CustomCommitteeSearchControllerTest {
  @isTest(SeeAllData=true)
	public static void testCustomCommitteeMemberSearchController () {
		System.assert(CustomCommitteeMemberSearchController.searchCommittees('a').size() > 0);
		System.assertEquals(null, CustomCommitteeMemberSearchController.searchCommittees('test search'));
	}
}