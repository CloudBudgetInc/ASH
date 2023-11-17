@isTest 
public with sharing class CommitteeListSearchControllerTest {

    @isTest(SeeAllData=true)
	public static void testCommitteeListSearchController() {
        Test.startTest();
        System.assert(CommitteeListSearchController.getCommittees('ASH','', true).size() > 0);
        System.assert(CommitteeListSearchController.getCommittees('','Standing Committee', true).size() > 0);
        System.assert(CommitteeListSearchController.getCommittees('','Standing Committee', false).size() > 0);
        System.assert(CommitteeListSearchController.getCommittees('ASH','Standing Committee', true).size() > 0);
        System.assertEquals(0, CommitteeListSearchController.getCommittees('NonExistentSearch','Standing Committee', false).size());
        System.assert(CommitteeListSearchController.getCustomerClasses().size() > 0);
        Test.stopTest();
    }

}