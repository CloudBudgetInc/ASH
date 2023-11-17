@IsTest
public with sharing class VeevaCalloutClassTest {
	@IsTest
	public static void testVeevaAuth() {
		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assert(VeevaCalloutClass.authenticateVeeva('https://ashrc-etmf.veevavault.com/api/v20.1/').getStatus().equals('OK'));
	}

	@IsTest
	public static void testVeevaJSON() {
		Contact c = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test@gmail.com'
		);
		insert c;

		Contact_Junction__c cj = new Contact_Junction__c(Contact__c = c.Id);

		System.assertEquals('{ }', VeevaCalloutClass.createContactJSON(cj, ''));
	}

	@IsTest(SeeAllData=true)
	public static void testVeevaCreateContact() {
		Contact c = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test@gmail.com'
		);
		insert c;

		Contact_Junction__c cj = new Contact_Junction__c(Contact__c = c.Id);
		insert cj;

		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assert(VeevaCalloutClass.createVeevaContactRecord(cj.Id, c.Id) == null);
	}

	@IsTest
	public static void testVeevaCreateContactAddr() {
		Contact c = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test@gmail.com'
		);
		insert c;

		Account acct = new Account(
			Name = 'Test CTU Org'
		);
		insert acct;

		Clinical_Trial_Unit__c ctu = new Clinical_Trial_Unit__c(
			Name = 'Test CTU Org',
			Primary_Site__c = acct.Id
		);
		insert ctu;

		Address__c addr = new Address__c(
			CTN__c = ctu.Id,
			Street__c = '123 Main St.',
			City__c = 'LA'
		);
		insert addr;

		Contact_Junction__c cj = new Contact_Junction__c(
			Contact__c = c.Id,
			Address__c = addr.Id
		);
		insert cj;

		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assert(VeevaCalloutClass.createVeevaContactRecord(cj.Id, c.Id) == null);
	}

	@IsTest
	public static void testVeevaCreateCTUAddress() {
		Account acct = new Account(
			Name = 'Test CTU Org'
		);
		insert acct;

		Clinical_Trial_Unit__c ctu = new Clinical_Trial_Unit__c(
			Name = 'Test CTU Org',
			Primary_Site__c = acct.Id
		);
		insert ctu;

		Address__c addr = new Address__c(
			CTN__c = ctu.Id,
			Street__c = '123 Main St.',
			City__c = 'LA'
		);
		insert addr;

		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assert(VeevaCalloutClass.createVeevaLocationRecord(addr.Id) == null);
	}

	@IsTest
	public static void testVeevaCreateDHAddress() {
		Account acct = new Account(
			Name = 'DH Test Org'
		);
		insert acct;

		Data_Hub_Contributor__c dh = new Data_Hub_Contributor__c(
			Name = 'DH Test Org',
			Institution__c = acct.Id
		);
		insert dh;

		Address__c addr = new Address__c(
			Data_Hub__c = dh.Id,
			Street__c = '123 Main St.',
			City__c = 'LA'
		);
		insert addr;

		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assert(VeevaCalloutClass.createVeevaLocationRecord(addr.Id) == null);
	}

	@IsTest
	public static void testVeevaCreatePersonLocation() {
		Contact c = new Contact(
			FirstName = 'Test',
			LastName = 'User',
			Email = 'test@gmail.com'
		);
		insert c;

		Contact_Junction__c cj = new Contact_Junction__c(Contact__c = c.Id);
		insert cj;

		// Perform test
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
		Test.stopTest();

		System.assert(VeevaCalloutClass.createVeevaPersonLocationRecord(cj.Id) == null);
	}
}