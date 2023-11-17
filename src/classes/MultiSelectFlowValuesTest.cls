@isTest(SeeAllData=true)
public with sharing class MultiSelectFlowValuesTest {

    @isTest(SeeALlData=true)
    public static void testCheckValues() {
        List<String> invalidList = new List<String>();
        System.assertEquals(null, MultiSelectFlowValues.CheckValues(invalidList));

        List<String> validList = new List<String>();
        validList.add('123;123');
        validList.add('321;321');
        validList.add('213;132');

        System.assertEquals(3, MultiSelectFlowValues.CheckValues(validList).size());
    }
}