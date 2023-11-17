({
	getReportData: function(cmp) {
		function callback(cmp, response){
			let res = response.getReturnValue();
			let reportLines = [];
			for(let i = 0; i < res.length; i++){
				reportLines.push(
					{
						class : '',
						labels : ['Program', 'Project', 'Income Statement Group', 'General Ledger Account', 'Account-Subaccount','Label','2022 Actual','2023 Approved Budgeted','2024 Proposed Budgeted',
						'Proposed FY24 vs Approved FY23 ($)','Proposed FY24 vs Approved FY23 (%)'],
						reportCells : [
							{value: res[i].c2g__Dimension2__r !== undefined ? res[i].c2g__Dimension2__r.Name : ''},
							{value: res[i].c2g__Dimension2__r !== undefined ? res[i].c2g__Dimension3__r.Name : ''},
							{value: res[i].Income_Statement_Group__c},
							{value: res[i].c2g__GeneralLedgerAccount__r !== undefined ? res[i].c2g__GeneralLedgerAccount__r.Name : ''},
							{value: res[i].Account_Subaccount__c},
							{value: ''},
							{value: res[i].c2g__DualValue__c},
							{value: res[i].c2g__DualValue__c},
							{value: res[i].c2g__DualValue__c}
						]
					}
				);
			}
			let excelDataValue = {
				columnMode : false,
				reportColumns: [
					{title : 'Program', class : '', bgColor : '', bold : '', periodName : ''},
					{title : 'Project', class : '', bgColor : '', bold : '', periodName : ''},
					{title : 'Income Statement Group', class : '', bgColor : '', bold : '', periodName : ''},
					{title : 'General Ledger Name', class : '', bgColor : '', bold : '', periodName : ''},
					{title : 'Account-Subaccount', class : '', bgColor : '', bold : '', periodName : ''},
					{title : 'Label', class : '', bgColor : '', bold : '', periodName : ''},
					{title : '2022 Actual', class : '', bgColor : '', bold : '', periodName : ''},
					{title : '2023 Approved Budgeted', class : '', bgColor : '', bold : '', periodName : ''},
					{title : '2024 Proposed Budgeted', class : '', bgColor : '', bold : '', periodName : ''},
					{title : 'Proposed FY24 vs Approved FY23 ($)', class : '', bgColor : '', bold : '', periodName : ''},
					{title : 'Proposed FY24 vs Approved FY23 (%)', class : '', bgColor : '', bold : '', periodName : ''}
				],
				reportLines : reportLines,
				name : 'Excel Report',
				description : 'description',
				reportGroupColumns : [{label : 'Program'}, {label : 'Project'}]

			};
			cmp.set('v.excelDataValue', excelDataValue);
		}
		_CBRequest(
		cmp,
		'c.getReportDataServer',
		null,
		null,
		callback,
		'Report Data loaded',
		'Failed to load Report Data',
		true
		);
	}
});