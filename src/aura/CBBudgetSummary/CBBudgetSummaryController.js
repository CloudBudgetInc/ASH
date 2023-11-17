({
	doInit: function (cmp, event, helper) {
		_showSpinner(cmp);
		document.title = _TEXT.APP_SHEET.MODULE_HEADER;
		cmp.set('v.incomeData', null);
		cmp.set('v.expenseData', null);
		setTimeout(function () {
			helper.helpGetAllApps(cmp);
			helper.helpGetRootApp(cmp);
			helper.helpGetTableHeaders(cmp);
			helper.helpGetAllAccountsAndDimension(cmp);
		}, 10);
	},

	refreshData: function (cmp, event, helper) {
		_showSpinner(cmp);
		window.setTimeout(
			$A.getCallback(function () {
				helper.helpRefreshData(cmp);
			}), 10
		);

	},

	redirectToBudgetApp: function (cmp, event, helper) {
		let appId = cmp.get("v.app.Id");
		function redirect(cmp, response) {
			const cmpName = response.getReturnValue();
			let param = {
				recordId : appId
			};
			_CBRedirect.toComponent(cmpName, param);
		}
		_CBRequest(
			cmp,
			"c.getProperlyCmpNameServer",
			{
				"recordId": appId,
				"dimensionId": null,
				"createNewTag": false
			},
			null,
			redirect,
			null,
			'Redirect Error'
		);
	},

	/////// EXCEL

	downloadExcelConsolidated: function (cmp, event, helper) {
		setTimeout(function () {
			helper.helpDownloadExcelConsolidated(cmp, cmp.get('v.incomeData'), cmp.get('v.expenseData'));
		},10);
	},
	downloadExcelSplitBySheets: function (cmp, event, helper) {
		setTimeout(function () {
			helper.helpDownloadExcelSplitBySheets(cmp);
		},10);
	},
	backToMainTable: function (cmp, event, helper) {
		helper.helpBackToMainTable(cmp);
	}
});