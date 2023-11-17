@isTest
public with sharing class CBTestLocal {
	static List<cb4__CBDimension__c> d;
	static Map<String, Id> dMap = cb4.CBUtils.dimensionNameIdMap;
	static List<cb4.CBSO> SO;
	static List<String> s;
	static List<cb4.CBRow> rows;
	static Date dt;
	static Object o, o1;
	static Id BY_ID { // BY Tag Id
		get {
			if (BY_ID == null) {
				List<cb4__CBTag__c> t = [SELECT Id FROM cb4__CBTag__c WHERE cb4__DimensionName__c = :cb4.CBConstant.BUDGET_YEAR_DIM];
				if (t.size() > 0) BY_ID = t[0].Id;
			}
			return BY_ID;
		}
		set;
	}

	public static String CRON_EXP = '0 0 * * * ? *';

	/**
	 * Debug mode. If ec is 'true', extra classes will be skip
	 */
	static Boolean ec = false;

	@testSetup static void setup() {
		d = new List<cb4__CBDimension__c>();
		add(cb4.CBConstant.ACCOUNT_DIM);
		add(cb4.CBConstant.ACCOUNT_SET_DIM);
		add(cb4.CBConstant.ACCOUNT_PARENT_DIM);
		add(cb4.CBConstant.ACCOUNT_SUBTYPE_DIM);
		add(cb4.CBConstant.ACCOUNT_TYPE_DIM);
		add(cb4.CBConstant.BUDGET_APP_TEMPLATE_DIM);
		add(cb4.CBConstant.BUDGET_APP_DIM);
		add(cb4.CBConstant.BUDGET_APP_TEMPLATE_EXTENSION_DIM);
		add(cb4.CBConstant.BUDGET_APP_AMOUNT_DIM);
		add(cb4.CBConstant.BUDGET_YEAR_DIM);
		add(cb4.CBConstant.CALCULATION_RULE_DIM);
		add(cb4.CBConstant.CALCULATION_RULE_SET_DIM);
		add(cb4.CBConstant.CASE_DIM);
		add(cb4.CBConstant.DEPARTMENT_DIM);
		add(cb4.CBConstant.ENTRY_DIM);
		add(cb4.CBConstant.ENTRY_AMOUNT_DIM);
		add(cb4.CBConstant.ENTRY_TYPE_DIM);
		add(cb4.CBConstant.ENTRY_CLASS_DIM);
		add(cb4.CBConstant.EMPLOYEE_DIM);
		add(cb4.CBConstant.EMPLOYEE_SET_DIM);
		add(cb4.CBConstant.HELP_SET_TAG);
		add(cb4.CBConstant.INTERIM_DATA_DIM);
		add(cb4.CBConstant.PERIOD_DIM);
		add(cb4.CBConstant.PAYROLL_CALENDAR_DIM);
		add(cb4.CBConstant.PAYROLL_CALENDAR_PERIOD_DIM);
		add(cb4.CBConstant.LINK_SET);
		add(cb4.CBConstant.RATE_DIM);
		add(cb4.CBConstant.RATE_TERM_DIM);
		add(cb4.CBConstant.RATE_TYPE_DIM);
		add(cb4.CBConstant.REDIRECT_SET_TAG);
		add(cb4.CBConstant.TAX_DIM);
		add(cb4.CBConstant.TAX_RULE_ITEM_DIM);
		add(cb4.CBConstant.TAX_TYPE_DIM);
		add(cb4.CBConstant.TIME_REPORT_DIM);
		add(cb4.CBConstant.TIME_REPORT_LINE_DIM);
		add(cb4.CBConstant.UNIT_DIM);
		add(cb4.CBConstant.PAYROLL_RUN_EVENT_DIM);
		add(cb4.CBConstant.WAGE_PRIMARY_DOCUMENT_DIM);
		add(cb4.CBConstant.WAGE_PRIMARY_DOCUMENT_AMOUNT_DIM);
		add(cb4.CBConstant.WAGE_PRIMARY_DOCUMENT_TAX_AMOUNT_DIM);
		add(cb4.CBConstant.PAYROLL_CONTAINER);
		add(cb4.CBConstant.PAYROLL_SUPPLEMENTAL_CONTAINER);
		add(cb4.CBConstant.POSTING_RULE_CONFIGURATION_DIM);
		add(cb4.CBConstant.POSTING_RULE_CONFIGURATION_SET_DIM);
		add(cb4.CBConstant.FORECAST_SETTING_DIM);
		add('CB Reporting Balance');
		add('CB_FF1');
		add('CB_FF2');
		add('CB_FF3');
		add('CB_FF4');
		add('Subaccount Code');
		add('Budget App SubAmount');
		add('Combination Rule');
		add('Scenario');
		insert d; // 1

		String scenDimId;
		for (cb4__CBDimension__c dim : d) {
			if (dim.Name == 'Scenario') scenDimId = String.valueOf(dim.Id);
			if (dim.Name == cb4.CBConstant.BUDGET_APP_AMOUNT_DIM || dim.Name == cb4.CBConstant.BUDGET_APP_TEMPLATE_EXTENSION_DIM) {
				for (Integer i = 1; i <= 10; i++) {
					dim.put('cb4__Text' + String.valueOf(i) + '__c', '{"v":"TEST","t":"Program","e":"Table","p":"-","b":"body","c":"1","o":"0","vi":"t","to":"","r":"f","d":"f","a":"l","u":""}');
					dim.put('cb4__Decimal' + String.valueOf(i) + '__c', '{"v":"TEST","t":"Program","e":"Table","p":"-","b":"body","c":"1","o":"0","vi":"t","to":"","r":"f","d":"f","a":"l","u":""}');
					if (i > 5) continue;
					dim.put('cb4__Boolean' + String.valueOf(i) + '__c', '{"v":"TEST","t":"Program","e":"Table","p":"-","b":"body","c":"1","o":"0","vi":"t","to":"","r":"f","d":"f","a":"l","u":""}');
				}
			}
		}
		for (cb4__CBDimension__c dim : d) {
			if (dim.Name == 'Budget App Template') dim.cb4__Dimension6__c = '{"v":"' + scenDimId + '","t":"Program","e":"Table","p":"-","b":"body","c":"1","o":"0","vi":"t","to":"","r":"f","d":"f","a":"l","u":""}';
		}
		update d;

		cb4__CBDimension__c appDim = [SELECT Id FROM cb4__CBDimension__c WHERE Name = :cb4.CBConstant.BUDGET_APP_DIM LIMIT 1];
		cb4__CBDimension__c depDim = [SELECT Id FROM cb4__CBDimension__c WHERE Name = :cb4.CBConstant.DEPARTMENT_DIM LIMIT 1];
		String fieldContent = '{"e":"Table","p":"-","v":"' + depDim.Id + '","to":"0","b":"header","c":"1","o":"0","vi":"t","t":"Department","a":"l","r":"f","d":"f","u":""}';
		appDim.cb4__Dimension4__c = appDim.cb4__Dimension5__c = appDim.cb4__Dimension6__c = appDim.cb4__Dimension7__c = appDim.cb4__Dimension8__c = appDim.cb4__Dimension9__c = appDim.cb4__Dimension10__c = fieldContent;
		update appDim;

		cb4.CBUtils.dimensionNameIdMap = null;
		dMap = cb4.CBUtils.dimensionNameIdMap;

		List<cb4__CBTag__c> t1 = new List<cb4__CBTag__c>(); // first order insert
		cb4__CBTag__c BYT = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.BUDGET_YEAR_DIM), Name = '1984', cb4__Start__c = Date.newInstance(1984, 1, 1), cb4__End__c = Date.newInstance(1984, 12, 31));
		cb4__CBTag__c DEP = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.DEPARTMENT_DIM), Name = 'NY');
		cb4__CBTag__c ACCTYPEI = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.ACCOUNT_TYPE_DIM), Name = 'Income');
		cb4__CBTag__c ACCTYPEE = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.ACCOUNT_TYPE_DIM), Name = 'Expense');
		cb4__CBTag__c ETYPE = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.ENTRY_TYPE_DIM), Name = 'Expense');
		cb4__CBTag__c ECLASS = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.ENTRY_CLASS_DIM), Name = 'Planned');
		cb4__CBTag__c BATEMPL = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.BUDGET_APP_TEMPLATE_DIM), Name = 'Tmpl');
		cb4__CBTag__c forecast = new cb4__CBTag__c(cb4__Dimension__c = dMap.get('Scenario'), Name = 'Forecast');
		cb4__CBTag__c testtag = new cb4__CBTag__c(cb4__Dimension__c = dMap.get('Scenario'), Name = 'TEST LOCK TAG');
		t1.add(BYT);
		t1.add(DEP);
		t1.add(ACCTYPEI);
		t1.add(ACCTYPEE);
		t1.add(ETYPE);
		t1.add(ECLASS);
		t1.add(BATEMPL);
		t1.add(forecast);
		t1.add(testtag);
		insert t1; //3

		List<cb4__CBTag__c> t2 = new List<cb4__CBTag__c>(); // second order insert
		cb4__CBTag__c ENTRY = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.ENTRY_DIM), Name = 'Entry', cb4__Tag1__c = BYT.Id, cb4__Tag2__c = DEP.Id, cb4__Tag3__c = ETYPE.Id, cb4__Tag4__c = ECLASS.Id);
		cb4__CBTag__c PERIOD = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.PERIOD_DIM), Name = 'JAN', cb4__Tag1__c = BYT.Id, cb4__OrderNumber__c = 1, cb4__Start__c = Date.newInstance(1984, 1, 1), cb4__End__c = Date.newInstance(1984, 1, 31));
		cb4__CBTag__c ACCST = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.ACCOUNT_SUBTYPE_DIM), Name = 'Travel', cb4__Tag1__c = ACCTYPEE.Id);
		t2.add(ENTRY);
		t2.add(PERIOD);
		t2.add(ACCST);
		insert t2; // 4

		List<cb4__CBTag__c> t3 = new List<cb4__CBTag__c>(); // third order insert
		cb4__CBTag__c ACC = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.ACCOUNT_DIM), Name = 'Air', cb4__Tag1__c = ACCST.Id);
		t3.add(ACC);
		insert t3; //5

		List<cb4__CBTag__c> t4 = new List<cb4__CBTag__c>(); // 4-th order insert
		cb4__CBTag__c ENTRYAM = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.ENTRY_AMOUNT_DIM), cb4__Tag1__c = ENTRY.Id, cb4__Tag2__c = ACC.Id, cb4__Tag3__c = PERIOD.Id, cb4__Decimal1__c = 1, cb4__Text2__c = 'Dr');

		cb4__CBTag__c CR = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.CALCULATION_RULE_DIM), Name = 'CRULE', cb4__Tag3__c = PERIOD.Id, cb4__Tag1__c = ACC.Id);
		t4.add(ENTRYAM);
		t4.add(CR);
		insert t4; // 6


		List<sObject> obj = new List<sObject>();
		cb4__CBalanceRule__c br = new cb4__CBalanceRule__c(cb4__AmountField__c = 'cb4__Decimal1__c', cb4__ColumnField__c = 'cb4__Tag3__c', cb4__DimensionType__c = dMap.get(cb4.CBConstant.ENTRY_AMOUNT_DIM));
		obj.add(br);
		cb4__CBUserContext__c uc = cb4__CBUserContext__c.getInstance(UserInfo.getUserId());
		uc = new cb4__CBUserContext__c(cb4__Dimension1__c = dMap.get(cb4.CBConstant.BUDGET_YEAR_DIM), cb4__Tag1__c = BYT.Id, cb4__Tag2__c = BYT.Id, cb4__Tag3__c = BYT.Id, cb4__Tag4__c = BYT.Id, cb4__Tag5__c = BYT.Id);
		obj.add(uc);
		cb4__CBLog__c l = new cb4__CBLog__c(cb4__Type__c = 'DEBUG', cb4__Title__c = 't', cb4__Description__c = 'd');
		obj.add(l);
		cb4__CBLoadRule__c lrACC = new cb4__CBLoadRule__c(Name = 'Account', cb4__Column1__c = '{"Tag1__c":"SubType","required":"false","unique":"true"}') ;
		obj.add(lrACC);
		cb4__CBLoadRule__c lrEMP = new cb4__CBLoadRule__c(Name = 'Member', cb4__Column1__c = '{"Tag1__c":"SubType","required":"false","unique":"true"}') ;
		obj.add(lrEMP);
		insert obj; // 2

	}

	@isTest static void CBBudgetApplication() {
		if (ec) return;
		cb4__CBTag__c templ = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.BUDGET_APP_TEMPLATE_DIM), Name = 't');
		insert templ;
		Id perId = [SELECT Id FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Period'][0].Id;
		cb4__CBTag__c app = CBBudgetApplication.getNewBudgetAppServer(null);
		System.assert(app != null);
		app.cb4__Tag3__c = BY_ID;
		app.cb4__Tag2__c = templ.Id;
		app.OwnerId = System.UserInfo.getUserId();
		insert app;

		cb4__CBTag__c acc = [SELECT Id FROM cb4__CBTag__c WHERE cb4__Dimension__c = :dMap.get(cb4.CBConstant.ACCOUNT_DIM) LIMIT 1][0];
		cb4.CBRow expRow = new cb4.CBRow();
		expRow.app = app.Id;
		expRow.account = acc.Id;
		expRow.title = 't';
		expRow.ie = 'expense';
		expRow.rowValues = new List<Decimal>{
				1, 1
		};
		expRow.quantityValues = new List<Decimal>{
				1, 1
		};
		expRow.priceValues = new List<Decimal>{
				1, 1
		};
		cb4.CBRow totalRow = new cb4.CBRow();
		totalRow.app = app.Id;
		totalRow.title = 'expense';
		totalRow.ie = 'expense';
		totalRow.rowValues = new List<Decimal>{
				1, 1
		};
		totalRow.quantityValues = new List<Decimal>{
				1, 1
		};
		totalRow.priceValues = new List<Decimal>{
				1, 1
		};
		o = CBBudgetApplication.saveAppTagsServer(app, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test1', cb4__Decimal1__c = 100, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId)
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test2', cb4__Decimal1__c = 100, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId)
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test3', cb4__Decimal1__c = 100, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId)
		});

		List<cb4__CBTag__c> r = CBBudgetApplication.getBudgetAppsServer(app.Id, null);
		r = CBBudgetApplication.getBudgetAppsServer(null, null);

		System.assert(r.size() > 0);

		templ = CBBudgetApplication.getBudgetTemplateServer(r[0].Id);
		System.assertNotEquals(templ, null);
		o = CBBudgetApplication.getBudgetAppDimensionServer();

		o = CBBudgetApplication.getTableHeadersServer(r[0].Id);
		o = CBBudgetApplication.getDownUpSubRowsServer(r[0].Id, 'expense');
		o = CBBudgetApplication.getTopDownSubRowsServer(r[0].Id, 'expense');
		o = CBBudgetApplication.getAccountsServer(r[0].Id);
		o = CBBudgetApplication.getInitialSOServer();
		o = CBBudgetApplication.getFilterCategoriesSOServer();
		o = CBBudgetApplication.getAllChildrenIdsServer(r[0].Id);
		o = CBBudgetApplication.getRowsServer(r[0].Id, null, 'total', null);
		o = CBBudgetApplication.getDownUpSubLines(r[0].Id, 'subsidiary');
		CBBudgetApplication.saveChatServer(r[0].Id, '');
		o = CBBudgetApplication.saveTopDownSubLinesServer(new List<cb4.CBRow>{
				expRow
		});
		o = CBBudgetApplication.getCalcRulesSyntheticLines(r[0].Id, new List<cb4.CBRow>{
				expRow
		}, new List<cb4.CBRow>{
				expRow
		}, null, 1);
		o = CBBudgetApplication.getTagNamesServer(new List<String>{
				BY_ID
		});

	}

	@isTest static void CBBudgetApplication2() {
		if (ec) return;

		cb4__CBTag__c templ = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.BUDGET_APP_TEMPLATE_DIM), Name = 't');
		insert templ;
		Id perId = [SELECT Id FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Period'][0].Id;
		cb4__CBTag__c app = CBBudgetApplication.getNewBudgetAppServer(null);
		System.assert(app != null);
		app.cb4__Tag3__c = BY_ID;
		app.cb4__Tag2__c = templ.Id;
		app.Name = 'TEST1';
		app.OwnerId = System.UserInfo.getUserId();
		app.Id = CBBudgetApplication.saveAppTagsServer(app, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test11', cb4__Decimal1__c = 101, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'expense')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test22', cb4__Decimal1__c = 102, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'income')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test33', cb4__Decimal1__c = 103, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'total')
		});

		CBBudgetApplication.reMapPeriodsIfNeeded(new List<cb4__CBTag__c>{
				new cb4__CBTag__c()
		}, app.Id);

		o = CBBudgetApplication.getCurrentUserInterfaceSettingsListServer('Main');
		o = CBBudgetApplication.getAllAccountsAndDimensionsServer();
		o = CBBudgetApplication.getAppDimensionsMap();
		o = CBBudgetApplication.getPriceQuantityObjectServer();
		o = CBBudgetApplication.getEmployeeRateObjectServer();
		o = CBBudgetApplication.refineStringToId('test');
		o = CBBudgetApplication.getSubLineKey(new cb4__CBTag__c());
		o = CBBudgetApplication.getAccount('test');


		cb4__CBTag__c app2 = CBBudgetApplication.getNewBudgetAppServer(null);
		app2.cb4__Tag1__c = app.Id;
		app2.OwnerId = System.UserInfo.getUserId();
		app2.Name = 'TEST2';
		app2.Id = CBBudgetApplication.saveAppTagsServer(app2, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test1', cb4__Decimal1__c = 101, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'expense')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test2', cb4__Decimal1__c = 102, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'income')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test3', cb4__Decimal1__c = 103, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'total')
		});
		List<cb4__CBTag__c> r = CBBudgetApplication.getBudgetAppsServer(null, null);
		System.assert(r.size() > 0);
	}


	@isTest static void CBBudgetApplication3() {
		if (ec) return;
		cb4__CBTag__c templ = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.BUDGET_APP_TEMPLATE_DIM), Name = 't');
		insert templ;
		cb4__CBTag__c app = CBBudgetApplication.getNewBudgetAppServer(null);
		System.assert(app != null);
		app.cb4__Tag3__c = BY_ID;
		app.cb4__Tag2__c = templ.Id;
		app.OwnerId = System.UserInfo.getUserId();
		insert app;

		List<cb4__CBTag__c> r = CBBudgetApplication.getBudgetAppsServer(null, null);
		o = CBBudgetApplication.getExtraDimensionsSOServer(r[0].Id);
		o = CBBudgetApplication.checkIfApprovingAllowedServer(r[0].Id);
		o = CBBudgetApplication.getAppLineDimensionsMap(r[0].Id);
		o = CBBudgetApplication.getAppNavigationServer(r[0].Id);
		CBBudgetApplication.calculateAppTotals(r[0], new List<cb4__CBTag__c>());
		CBBudgetApplication.updateApps();
		CBBudgetApplication.cg();
		CBBudgetApplication.insertBackupLog(r[0].Id, 'test', 'test');
		List<cb4__CBLog__c> logList = CBBudgetApplication.getBackupLogList(r[0].Id, '01-02-2022', '01-02-2024');
	}

	@isTest static void CBBudgetApplication4() {
		if (ec) return;

		cb4__CBTag__c templ = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.BUDGET_APP_TEMPLATE_DIM), Name = 't');
		insert templ;
		Id perId = [SELECT Id FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Period'][0].Id;
		cb4__CBTag__c app = CBBudgetApplication.getNewBudgetAppServer(null);
		System.assert(app != null);
		app.cb4__Tag3__c = BY_ID;
		app.cb4__Tag2__c = templ.Id;
		app.Name = 'TEST1';
		app.OwnerId = System.UserInfo.getUserId();
		app.Id = CBBudgetApplication.saveAppTagsServer(app, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test11', cb4__Decimal1__c = 101, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'expense')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test22', cb4__Decimal1__c = 102, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'income')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test33', cb4__Decimal1__c = 103, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'total')
		});
		o = CBBudgetApplication.getBAListServer(null);
		o = CBBudgetApplication.voidMethod();
		o = CBBudgetApplication.getAppPeriodsServer(app.Id);
		o = CBBudgetApplication.getSimpleLineKey(new cb4__CBTag__c(), app.Id);
		String s = CBBudgetApplication.getUniqueLabel('PRE', dMap.get(cb4.CBConstant.BUDGET_APP_AMOUNT_DIM));
		CBBudgetApplication.calculateAppTotals(app, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test1', cb4__Decimal1__c = 101, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text2__c = 'income')
		});
		CBBudgetApplication.deleteAppServer(app.Id);
	}

	@isTest static void CBBudgetApplicationASH(){
		cb4__CBTag__c templ = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.BUDGET_APP_TEMPLATE_DIM), Name = 't');
		cb4__CBTag__c t1 = new cb4__CBTag__c(cb4__Dimension__c = dMap.get('CB_FF1'), Name = '175');
		cb4__CBTag__c t2 = new cb4__CBTag__c(cb4__Dimension__c = dMap.get('CB_FF2'), Name = '368');
		cb4__CBTag__c t3 = new cb4__CBTag__c(cb4__Dimension__c = dMap.get('CB_FF3'), Name = '59' );
		cb4__CBTag__c t4 = new cb4__CBTag__c(cb4__Dimension__c = dMap.get('CB_FF4'), Name = '70' );
		insert new List<cb4__CBTag__c> {templ, t1, t2, t3, t4};
		Id perId = [SELECT Id FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Period'][0].Id;
		cb4__CBTag__c app = CBBudgetApplication.getNewBudgetAppServer(null);
		System.assert(app != null);
		app.cb4__Tag3__c = BY_ID;
		app.cb4__Tag2__c = templ.Id;
		app.Name = 'TEST1';
		app.OwnerId = System.UserInfo.getUserId();
		app.Id = CBBudgetApplication.saveAppTagsServer(app, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test11', cb4__Decimal1__c = 101, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'expense')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test22', cb4__Decimal1__c = 102, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'income')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test33', cb4__Decimal1__c = 103, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'total')
		});
		cb4__CBTag__c acc = [SELECT Id FROM cb4__CBTag__c WHERE cb4__Dimension__c = :dMap.get(cb4.CBConstant.ACCOUNT_DIM) LIMIT 1][0];
		cb4.CBRow expRow = new cb4.CBRow();
		expRow.app = app.Id;
		expRow.account = acc.Id;
		expRow.title = 't';
		expRow.ie = 'expense';
		expRow.rowValues = new List<Decimal>{
				1, 1
		};
		expRow.quantityValues = new List<Decimal>{
				1, 1
		};
		expRow.priceValues = new List<Decimal>{
				1, 1
		};
		s = CBBudgetApplication.validateWithCombinationRuleServer(new List<cb4.CBRow>{expRow}, app.Id, true);
		CBBudgetApplication.createCombinationRuleByAnalystNames('Air, 175, 368, 59, 70',app.Id);
		Map<String, List<cb4.CBRow>> slMap = CBBudgetApplication.getSubLinesServer(app.Id);
		CBBudgetApplication.setNewKeyByOldKeyToSubLinesServer(new List<String>{'1'},new List<String>{'2'});
		Boolean access = CBBudgetApplication.isUserHasAccessToEditBudgetServer(app.Id);
		access = CBBudgetApplication.hasUserNoAccessToApproveServer(app.Id);
		access = CBBudgetApplication.isUserAdminServer();
		app = CBBudgetApplication.changeLockStatusBudgetServer(app);
	}

	@IsTest static void CBASHControllerTests(){
		cb4__CBTag__c templ = new cb4__CBTag__c(cb4__Dimension__c = dMap.get(cb4.CBConstant.BUDGET_APP_TEMPLATE_DIM), Name = 't');
		Id perId = [SELECT Id FROM cb4__CBTag__c WHERE cb4__DimensionName__c = 'Period'][0].Id;
		cb4__CBTag__c app = CBBudgetApplication.getNewBudgetAppServer(null);
		System.assert(app != null);
		app.cb4__Tag3__c = BY_ID;
		app.cb4__Tag2__c = templ.Id;
		app.Name = 'TEST1';
		app.OwnerId = System.UserInfo.getUserId();
		app.Id = CBBudgetApplication.saveAppTagsServer(app, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test11', cb4__Decimal1__c = 101, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'expense')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test22', cb4__Decimal1__c = 102, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'income')
		}, new List<cb4__CBTag__c>{
				new cb4__CBTag__c(Name = 'test33', cb4__Decimal1__c = 103, cb4__Decimal2__c = 200, cb4__Decimal3__c = 300, cb4__Tag3__c = perId, cb4__Text1__c = 'total')
		});
		cb4__CBTag__c acc = [SELECT Id FROM cb4__CBTag__c WHERE cb4__Dimension__c = :dMap.get(cb4.CBConstant.ACCOUNT_DIM) LIMIT 1][0];
		cb4.CBRow expRow = new cb4.CBRow();
		expRow.app = app.Id;
		expRow.account = acc.Id;
		expRow.title = 't';
		expRow.ie = 'expense';
		expRow.rowValues = new List<Decimal>{
				1, 1
		};
		expRow.quantityValues = new List<Decimal>{
				1, 1
		};
		expRow.priceValues = new List<Decimal>{
				1, 1
		};

		s = new List<String>{CBASHController.currentFY};
		s = new List<String>{CBASHController.BLockSettings};
		dt = CBASHController.startFY;
		dt = CBASHController.startFY;
		Map<String, Object> mo = CBASHController.getParametersSOServer();
		s = new List<String>{CBASHController.getLockedPeriodServer('1984')};
		s = new List<String>{CBASHController.getBLockSettings()};
		SO = CBASHController.getPeriodsSOServer('1984');
		CBASHController.saveSubLinesServer(expRow, expRow, rows, app.Id, '', '');
		rows = CBASHController.getCBRowsFromServer('', app.Id);
		try {
			CBASHController.deleteSubLineServer(expRow, '');
		}catch (Exception e){}
		Map<Id, cb4__CBTag__c> tm = CBASHController.accountMap;
		List<String> ts = CBASHController.getDocumentsByRecordIdServer(app.Id);
		CBASHController.cg();
	}

	@IsTest static void CBAllocationFlow(){
		CBAllocationFlow.codeGen();
	}

	@IsTest static void CBRBUpdateScheduleTest() {
		Test.startTest();
		String jobId = System.schedule('testBasicScheduledApex3',
				CRON_EXP,
				new CBBudgetReportingBalanceUpdateSchedule());
		CronTrigger ct = [
				SELECT Id, CronExpression, TimesTriggered,
						NextFireTime
				FROM CronTrigger
				WHERE id = :jobId
		];
		System.assertEquals(CRON_EXP,
				ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}

	@isTest static void CBRBUpdate1Test() {
		Test.startTest();
		CBBudgetReportingBalanceUpdate1 runPuff1 = new CBBudgetReportingBalanceUpdate1();
		Test.stopTest();
	}

	@isTest static void CBRBUpdate2Test() {
		Test.startTest();
		CBBudgetReportingBalanceUpdate2 runPuff2 = new CBBudgetReportingBalanceUpdate2();
		Test.stopTest();
	}

	@isTest static void CBRBDeleteJobTest() {
		Test.startTest();
		CBDeleteBudgetFFRBJob dj = new CBDeleteBudgetFFRBJob();
		Test.stopTest();
	}

	@IsTest static void CBBudgetGeneratorTest(){
		CBStartPersonnelBudgetDataGeneration.codeGen();
		CBStartPersonnelBudgetDataDeletion.codeGen();
		CBBudgetDataGenerator.codeGen();
	}

	// SERVICE METHODS
	static void add(String s) {
		d.add(new cb4__CBDimension__c(Name = s, cb4__PageHeader__c = s + 's'));
	}
}