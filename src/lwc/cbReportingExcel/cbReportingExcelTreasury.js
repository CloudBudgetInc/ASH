import {
	CURRENCY_FMT,
	HEADER_FILL,
	HEADER_FONT,
	PERCENT_FMT,
	PROGRAM_PROJECT_SUB_LINE_FILL,
	PROGRAM_SUB_LINE_FILL,
	PROGRAM_SUB_LINE_FONT,
	SIMPLE_BORDERS,
	TOTAL_NET_LINE_FILL
} from "./cbReportingExcelStyles"
import {_message, _prompt, _setCell} from 'c/cbUtils';
import {addSpecialTableToMainSheet} from "./cbReportingExcelExhibitSpecialTable";
import {sumReportLines} from "./cbReportingExcelUtils";


let _this;
const setTreasuryContext = (context) => _this = context;
let separatedReportingBalances = {};// reporting balances separated by Dimension 2, key is Dim2 Name
const FIRST_SHEET_NAME = 'Summary';
let FILE_NAME = "ASH Budget Exhibit";

const SHEET_MAPPING = {
	'Annual Meeting (353)': 'Annual Meeting',
	'Publications (366)': 'Pubs',
	'Blood Advances (384)': 'Blood',
	'Blood Neoplasia (385)': 'Blood',
	'Blood VTH (387)': 'Blood',
	'Clinical News Magazine (376)': 'Blood',
	'How I Treat (149)': 'Blood',
	'Self Assessment Program (354)': 'Blood',
	'LLC (363)': 'HDQ',
	'Highlights of ASH (355)': 'Small Meetings',
	'Meeting on Genomic Editing (382)': 'Small Meetings',
	'Meeting on Hematologic Malignancies (378)': 'Small Meetings',
	'Meeting on Lymphoma Biology (234)': 'Small Meetings',
	'ASH Summit on Emerging Immunotherapies (399)': 'Small Meetings',
	'Awards (352)': 'Awards',
	'ASHRC Data Hub (395)': 'Data Hub',
	'ASHRC SCD Clinical Trials Network (392)': 'Clinical Trials',
};

/**
 * Common by Default if key is null
 */
const SHEET_TYPE = {
	'Summary': 'summary',
	'Small Meetings': 'pairs',
	'Pubs': 'pairs'
};

const manageDataAndGenerateTreasuryFile = () => {
	createDataSetsSeparatedBySheets();
	convertReportingBalancesToReportLines();
	console.log('separatedReportingBalances = ' + JSON.stringify(separatedReportingBalances));
};

/**
 * Method separates reporting balances by Dimension 2 Name and put extra lines to default list
 */
const createDataSetsSeparatedBySheets = () => {
	try {
		const firstSheetName = FIRST_SHEET_NAME;
		separatedReportingBalances = _this.reportingBalancesRaw.reduce((result, rb) => {
			try {
				const sheetName = SHEET_MAPPING[rb.c2g__Dimension2__r?.Name];

				let mainSheetList = result[firstSheetName];
				if (!mainSheetList) {
					mainSheetList = [];
					result[firstSheetName] = mainSheetList;
				}
				mainSheetList.push(rb);

				if (sheetName) {
					let sheetRBList = result[sheetName];
					if (!sheetRBList) {
						sheetRBList = [];
						result[sheetName] = sheetRBList;
					}
					sheetRBList.push(rb);
				}

				return result;
			} catch (e) {
				_message('error', 'Separate Treasury Data by Sheets Iterating Error: ' + e);
			}
		}, {});
	} catch (e) {
		_message('error', 'Separate Treasury Data by Sheets Error: ' + e);
	}
};

const convertReportingBalancesToReportLines = () => {
	Object.keys(separatedReportingBalances).forEach(sheetName => {
		let reportingBalances = separatedReportingBalances[sheetName];
		let sheetType = SHEET_TYPE[sheetName];
		let reportLines = getReportLinesFromReportingBalances(reportingBalances, sheetType);
		if (sheetType === 'summary') {
			addSummarySubTotalLines(reportLines);
		}
		//reportLines = addSubTotalLines(reportLines);
		//reportLines = calculateDifference(reportLines);
		separatedReportingBalances[sheetName] = reportLines;
	});
};

const getReportLinesFromReportingBalances = (RBList, sheetType) => {
	const reportLinesMap = {}; // key is dim2 Id and account Id
	RBList.forEach(rb => {
		try {
			let lineKey;
			if (sheetType === 'summary') {
				lineKey = rb.c2g__Dimension2__c + rb.c2g__Dimension3__c + rb.Income_Statement_Group__c;
			} else if (sheetType === 'pairs') {
				lineKey = rb.c2g__Dimension3__c + rb.Income_Statement_Group__c;
			} else {
				lineKey = rb.c2g__Dimension2__c + rb.c2g__Dimension3__c + rb.Income_Statement_Group__c + rb.c2g__GeneralLedgerAccount__c;
			}

			let reportLine = reportLinesMap[lineKey];
			if (!reportLine) {
				reportLine = getNewReportLine(rb, lineKey);
				reportLinesMap[lineKey] = reportLine;
			}
			if (rb.c2g__DualValue__c && rb.c2g__DualValue__c !== 0) {
				if (rb.c2g__Type__c === 'Actual') {
					let invertedIncomeActual = rb.c2g__DualValue__c;
					if (rb.Income_Statement_Group__c === 'Income') {
						invertedIncomeActual *= -1;
					}
					reportLine.actual += parseFloat(invertedIncomeActual);
				} else {
					if (rb.Year__c === _this.selectedBY) {
						reportLine.approvedBudget += parseFloat(rb.c2g__DualValue__c);
					} else {
						reportLine.processedBudget += parseFloat(rb.c2g__DualValue__c);
					}
				}
			}
		} catch (e) {
			_message('error', 'Get Treasury RL from RB Error : ' + e);
		}
	});
	return Object.values(reportLinesMap);
};

/**
 *
 * @param rb source reporting balance
 * @param lineKey key of reporting line
 * @return {lineKey: *, actual: number, programProject: (string|string), accountSubAccount: *, processedBudget: number, processedVsApprovedPercent: number, generalLedgerName: (string|string), incomeStatementGroup: *, processedVsApproved: number, approvedBudget: number, label: string} line for the excel table
 */
const getNewReportLine = (rb, lineKey) => {
	return {
		lineKey,
		incomeStatementGroup: rb.Income_Statement_Group__c,
		accountSubAccount: rb.Account_Subaccount__c,
		dim2Name: rb.c2g__Dimension2__r?.Name,
		dim3Name: rb.c2g__Dimension3__r?.Name,
		accName: rb.c2g__GeneralLedgerAccount__r?.Name,
		label: '',
		actual: 0,
		approvedBudget: 0, // selected BY
		processedBudget: 0, // next BY
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
	};
};

const addSummarySubTotalLines = (reportLines) => {
	const compareFn = (a, b) => {
		const first = a.incomeStatementGroup + a?.dim2Name + b?.dim3Name;
		const second = b.incomeStatementGroup + b?.dim2Name + b?.dim3Name;
		return first < second ? -1 : (first > second ? 1 : 0);
	};
	reportLines.sort(compareFn);
	const reportLinesGroup = {};
	reportLines.forEach(rl => {
		try {
			if (rl.incomeStatementGroup !== 'Income') rl.incomeStatementGroup = 'Expense';
			let key1 = rl.dim2Name === 'Awards (352)' ? rl.dim2Name + rl.dim3Name + rl.incomeStatementGroup : rl.dim2Name + rl.incomeStatementGroup;
			let key2 = rl.dim2Name === 'Awards (352)' ? rl.dim2Name + rl.incomeStatementGroup : false;
			rl.key1 = key1;
			rl.key2 = key2;

			rl.label = rl.dim2Name === 'Awards (352)' ? '>> ' + rl.dim3Name : rl.dim2Name;

			if (key2) {
				const groupRL = reportLinesGroup[key2];
				if (!groupRL) {
					rl.label = 'Awards (352)';
					reportLinesGroup[key2] = rl;
				} else {
					sumReportLines(groupRL, rl);
				}
			}

			const groupRL = reportLinesGroup[key1];
			if (!groupRL) {
				reportLinesGroup[key1] = rl;
			} else {
				sumReportLines(groupRL, rl);
			}
		} catch (e) {
			_message('error', 'Add Summary Sub Total Lines Error : ' + e);
		}
	});
	//console.log('reportLinesGroup = ' + JSON.stringify(reportLinesGroup));
	reportLines = Object.values(reportLinesGroup);
	const incomeLines = reportLines.filter(rl => rl.incomeStatementGroup === 'Income');
	const expenseLines = reportLines.filter(rl => rl.incomeStatementGroup !== 'Expense' && !rl.dim2Name.includes('Focus Fellowship Training Program'));
	const FFTPLines = reportLines.filter(rl => rl.dim2Name.includes('Focus Fellowship Training Program'));
	const totalIncomeRL = {
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Income Total'
	};
	incomeLines.forEach(rl => sumReportLines(totalIncomeRL, rl));

	const totalExpenseRL = {
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Expense Total'
	};
	expenseLines.forEach(rl => sumReportLines(totalExpenseRL, rl));

	reportLines = [...incomeLines, totalIncomeRL, ...expenseLines, totalExpenseRL];
	//console.log('incomeLines = ' + JSON.stringify(incomeLines));
	console.log('reportLines = ' + JSON.stringify(reportLines));
	//console.log('FFTPLines = ' + JSON.stringify(FFTPLines));
};

const addCommonSubTotalLines = (reportLines) => {

};

const addSubTotalLines = (reportLines) => {

};

const getNewIncomeStatementSubLine = (rl) => {
	return {
		type: 'incomeStatementGroup',
		programProject: rl.programProject,
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: rl.incomeStatementGroup + ' Subtotal'
	}
};

const getNewProgramProjectSubLine = (rl) => {
	return {
		type: 'programProject',
		programProject: rl.programProject,
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Project Net Income'
	}
};

const getNewProgramSubLine = (rl) => {
	return {
		type: 'program',
		programProject: rl.program,
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Program Net Income'
	}
};

/**
 * The main method to generate na Excel file
 */
const generateExcelFile = async () => {
	try {

		_this.showSpinner = true;
		let fileName = `${FILE_NAME} ${_this.selectedBY}`;
		fileName = await _prompt("Type the file name", fileName, 'File Name');
		if (!fileName || fileName.length < 1) {
			_this.showSpinner = false;
			return;
		}
		let workbook = new ExcelJS.Workbook();

		//Object.keys(this.separatedReportingBalances).forEach(name => console.log('SHEET NAME : ' + name));
		Object.keys(separatedReportingBalances).forEach(sheetName => {
			const lines = separatedReportingBalances[sheetName];
			let dim1Sheet = workbook.addWorksheet(sheetName, {views: [{state: "frozen", ySplit: 1, xSplit: 0}]});
			addHeaderAndSetColumnWidth(dim1Sheet);
			addReportLines(dim1Sheet, lines);
		});

		addSpecialTableToMainSheet(workbook.getWorksheet(FIRST_SHEET_NAME), separatedReportingBalances[FIRST_SHEET_NAME]);

		let data = await workbook.xlsx.writeBuffer();
		const blob = new Blob([data], {type: "application/octet-stream"});
		let downloadLink = document.createElement("a");
		downloadLink.href = window.URL.createObjectURL(blob);
		downloadLink.target = "_blank";
		downloadLink.download = fileName + ".xlsx";
		downloadLink.click();
		_this.showSpinner = false;
	} catch (e) {
		_message("error", "Reporting Excel generateExcelFile error: " + e);
		_this.showSpinner = false;
	}
};

let HEADER_PARAMS;
const getHeaderParams = () => {
	if (!HEADER_PARAMS) {
		const previousBY = _this.selectedBY - 1;
		const nextBY = +_this.selectedBY + 1;
		HEADER_PARAMS = [
			{title: 'Program-Project', width: 50},
			{title: 'Income Statement Group', width: 35},
			{title: 'General Ledger Name', width: 35},
			{title: 'Account-Subaccount', width: 20},
			{title: 'Label', width: 47},
			{title: `${previousBY} Actual`, width: 15},
			{title: `${_this.selectedBY} Approved Budgeted`, width: 22},
			{title: `${nextBY} Proposed Budgeted`, width: 22},
			{title: `Proposed FY${nextBY} vs Approved FY${_this.selectedBY} ($)`, width: 32},
			{title: `Proposed FY${nextBY} vs Approved FY${_this.selectedBY} (%)`, width: 32}
		];
	}
	return HEADER_PARAMS;
};

const addHeaderAndSetColumnWidth = (sheet) => {
	try {
		const headerRow = sheet.getRow(1);
		getHeaderParams().forEach((h, i) => {
			try {
				const headerCell = headerRow.getCell(i + 1);
				_setCell(headerCell, h.title, HEADER_FILL, HEADER_FONT, null, null, SIMPLE_BORDERS);
				sheet.getColumn(i + 1).width = h.width;
			} catch (e) {
				_message('error', 'Add Header Row Iteration Error : ' + e);
			}
		});
	} catch (e) {
		_message('error', 'Add Header Row Error : ' + e);
	}
};

const FIELD_ORDER = ['programProject', 'incomeStatementGroup', 'generalLedgerName', 'accountSubAccount', 'label', 'actual', 'approvedBudget', 'processedBudget', 'processedVsApproved', 'processedVsApprovedPercent'];

const addReportLines = (sheet, lines) => {
	try {
		let rowPosition = 2;
		let rowFill, rowFont, previousLineWasProgramSubtotal, previousLineWasSimple;
		lines.forEach(line => {
			if (previousLineWasProgramSubtotal) rowPosition++;
			const excelRow = sheet.getRow(rowPosition++);
			rowFill = getReportLineFill(line.type);
			rowFont = getReportLineFont(line.type);
			if (previousLineWasSimple) line.programProject = line.incomeStatementGroup = undefined;
			FIELD_ORDER.forEach((f, i) => {
				const cell = excelRow.getCell(i + 1);
				_setCell(cell, line[f], rowFill, rowFont, null, null, SIMPLE_BORDERS);
				if (['actual', 'approvedBudget', 'processedBudget', 'processedVsApproved'].includes(f)) cell.numFmt = CURRENCY_FMT;
				if (f === 'processedVsApprovedPercent') cell.numFmt = PERCENT_FMT;
			});
			previousLineWasProgramSubtotal = line.type === 'program';
			previousLineWasSimple = line.type === undefined;
		})
	} catch (e) {
		_message('error', 'Add Report Lines Error ' + e);
	}
};

const getReportLineFill = (type) => {
	switch (type) {
		case 'incomeStatementGroup':
			return HEADER_FILL;
		case 'programProject':
			return PROGRAM_PROJECT_SUB_LINE_FILL;
		case 'program':
			return PROGRAM_SUB_LINE_FILL;
		case 'totalNet':
			return TOTAL_NET_LINE_FILL;
		default:
			return undefined;
	}
};
const getReportLineFont = (type) => {
	switch (type) {
		case 'program':
			return PROGRAM_SUB_LINE_FONT;
		case 'totalNet':
			return PROGRAM_SUB_LINE_FONT;
		default:
			return undefined;
	}
};

export {setTreasuryContext, manageDataAndGenerateTreasuryFile}