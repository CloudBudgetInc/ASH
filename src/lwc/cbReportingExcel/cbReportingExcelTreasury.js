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
import {_getCopy, _message, _prompt, _setCell} from 'c/cbUtils';
import {subtractReportLines, sumReportLines} from "./cbReportingExcelUtils";


let _this;
const setTreasuryContext = (context) => _this = context;
let separatedReportingBalances = {};// reporting balances separated by Dimension 2, key is Dim2 Name
const FIRST_SHEET_NAME = 'Summary';
let FILE_NAME = "Treasury Report ";

const SHEET_MAPPING = {
	'Annual Meeting (353)': 'Annual Meeting',
	'Publications (366)': 'Blood',
	'Blood Advances (384)': 'Pubs',
	'Blood Neoplasia (385)': 'Pubs',
	'Blood VTH (387)': 'Pubs',
	'Clinical News Magazine (376)': 'Pubs',
	'How I Treat (149)': 'Pubs',
	'Self Assessment Program (354)': 'Pubs',
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
	generateExcelFile();
	//console.log('separatedReportingBalances = ' + JSON.stringify(separatedReportingBalances));
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
			reportLines = addSummarySubTotalLines(reportLines);
		} else if (sheetType === 'pairs') {
			//console.log('>>' + JSON.stringify(reportLines));
		} else {
			reportLines = addSimpleSubTotalLines(reportLines);
			console.log('>>' + JSON.stringify(reportLines));
		}
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
			const lineIsAward = rl.dim2Name === 'Awards (352)';
			let key1 = lineIsAward ? rl.dim2Name + rl.dim3Name + rl.incomeStatementGroup : rl.dim2Name + rl.incomeStatementGroup; // key of simple line
			let key2 = lineIsAward ? rl.dim2Name + rl.incomeStatementGroup : false;// key of sum Awards line
			rl.key1 = key1;
			rl.key2 = key2;
			if (lineIsAward) rl.isSubline = true;

			rl.label = lineIsAward ? '   ' + rl.dim3Name : rl.dim2Name;

			if (key2) {
				const groupRL = reportLinesGroup[key2];
				const rlCopy = _getCopy(rl);
				rlCopy.isSubline = false;
				if (!groupRL) {
					rlCopy.label = 'Awards TOTAL';
					reportLinesGroup[key2] = rlCopy;
				} else {
					sumReportLines(groupRL, rlCopy);
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
	const expenseLines = reportLines.filter(rl => rl.incomeStatementGroup !== 'Income' && !rl.dim2Name.includes('Focus Fellowship Training Program'));
	const FFTPLines = reportLines.filter(rl => rl.dim2Name.includes('Focus Fellowship Training Program'));
	const FFTPL = FFTPLines.length > 0 ? FFTPLines[0] : undefined;
	FFTPL.incomeStatementGroup = 'Reserve Expenses';
	const totalIncomeRL = {
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Income Total',
		type: 'programProject'
	};
	incomeLines.forEach(rl => {
		if (!rl.isSubline) sumReportLines(totalIncomeRL, rl);
	});

	const totalExpenseRL = {
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Expense Total',
		type: 'programProject'
	};
	expenseLines.forEach(rl => {
		if (!rl.isSubline) sumReportLines(totalExpenseRL, rl);
	});
	const totalNetIncomeBeforeFFTP = _getCopy(totalIncomeRL);
	totalNetIncomeBeforeFFTP.label = 'Total Net Income from Operations';
	subtractReportLines(totalNetIncomeBeforeFFTP, totalExpenseRL);

	const totalExpenseAfterFFTP = _getCopy(totalExpenseRL);
	totalExpenseAfterFFTP.label = 'Total Expense from Operations and Reserves';
	sumReportLines(totalExpenseAfterFFTP, FFTPL);

	const totalNetIncomeAfterFFTP = _getCopy(totalIncomeRL);
	totalNetIncomeAfterFFTP.label = 'Total Net Income from Operations and Reserves';
	subtractReportLines(totalNetIncomeAfterFFTP, totalExpenseAfterFFTP);
	/// clean extra income statement
	incomeLines.forEach((rl, i) => rl.incomeStatementGroup = i ? null : rl.incomeStatementGroup);
	expenseLines.forEach((rl, i) => rl.incomeStatementGroup = i ? null : rl.incomeStatementGroup);

	// null is empty row
	reportLines = [...incomeLines, totalIncomeRL, null, ...expenseLines, totalExpenseRL, null, totalIncomeRL, totalExpenseRL, totalNetIncomeBeforeFFTP, null,
		FFTPL, null, totalIncomeRL, totalExpenseAfterFFTP, totalNetIncomeAfterFFTP];

	//console.log('incomeLines = ' + JSON.stringify(incomeLines));
	//console.log('reportLines = ' + JSON.stringify(reportLines));
	//console.log('FFTPLines = ' + JSON.stringify(FFTPLines));
	return reportLines;
};

/**
 * SIMPLE LINES
 */
const addSimpleSubTotalLines = (reportLines) => {
	const compareFn = (a, b) => {
		const first = a.incomeStatementGroup + a?.accName;
		const second = b.incomeStatementGroup + b?.accName;
		return first < second ? -1 : (first > second ? 1 : 0);
	};
	reportLines.sort(compareFn);
	const reportLinesGroup = {};
	reportLines.forEach(rl => {
		try {
			if (rl.incomeStatementGroup !== 'Income') rl.incomeStatementGroup = 'Expense';
			let key1 = rl.incomeStatementGroup + rl.accName; // key of simple line
			rl.label = rl.accName;
			const groupRL = reportLinesGroup[key1];
			if (!groupRL) {
				reportLinesGroup[key1] = rl;
			} else {
				sumReportLines(groupRL, rl);
			}
		} catch (e) {
			_message('error', 'Add Simple Sub Total Lines Error : ' + e);
		}
	});
	//console.log('reportLinesGroup = ' + JSON.stringify(reportLinesGroup));
	reportLines = Object.values(reportLinesGroup);
	const incomeLines = reportLines.filter(rl => rl.incomeStatementGroup === 'Income');
	const expenseLines = reportLines.filter(rl => rl.incomeStatementGroup !== 'Income');
	const totalIncomeRL = {
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Income Total',
		type: 'programProject'
	};
	incomeLines.forEach(rl => sumReportLines(totalIncomeRL, rl));

	const totalExpenseRL = {
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Expense Total',
		type: 'programProject'
	};
	expenseLines.forEach(rl => sumReportLines(totalExpenseRL, rl));
	const totalNetIncome = _getCopy(totalIncomeRL);
	totalNetIncome.label = 'Total Net Income from Operations';
	subtractReportLines(totalNetIncome, totalExpenseRL);

	/// clean extra income statement
	incomeLines.forEach((rl, i) => rl.incomeStatementGroup = i ? null : rl.incomeStatementGroup);
	expenseLines.forEach((rl, i) => rl.incomeStatementGroup = i ? null : rl.incomeStatementGroup);

	// null is empty row
	reportLines = [...incomeLines, totalIncomeRL, null, ...expenseLines, totalExpenseRL, null, totalIncomeRL, totalExpenseRL, totalNetIncome];

	//console.log('incomeLines = ' + JSON.stringify(incomeLines));
	//console.log('reportLines = ' + JSON.stringify(reportLines));
	//console.log('FFTPLines = ' + JSON.stringify(FFTPLines));
	return reportLines;
};

/**
 * PAIR LINES
 */
const addPairSubTotalLines = (reportLines) => {
	const compareFn = (a, b) => {
		const first = a.incomeStatementGroup + a?.dim3Name;
		const second = b.incomeStatementGroup + b?.dim3Name;
		return first < second ? -1 : (first > second ? 1 : 0);
	};
	reportLines.sort(compareFn);
	const reportLinesGroup = {};
	reportLines.forEach(rl => {
		try {
			if (rl.incomeStatementGroup !== 'Income') rl.incomeStatementGroup = 'Expense';
			let key1 = rl.incomeStatementGroup + rl.dim3Name; // key of simple line
			rl.label = rl.dim3Name;
			const groupRL = reportLinesGroup[key1];
			if (!groupRL) {
				reportLinesGroup[key1] = rl;
			} else {
				sumReportLines(groupRL, rl);
			}
		} catch (e) {
			_message('error', 'Add Simple Sub Total Lines Error : ' + e);
		}
	});
	//console.log('reportLinesGroup = ' + JSON.stringify(reportLinesGroup));
	reportLines = Object.values(reportLinesGroup);
	const incomeLines = reportLines.filter(rl => rl.incomeStatementGroup === 'Income');
	const expenseLines = reportLines.filter(rl => rl.incomeStatementGroup !== 'Income');
	const totalIncomeRL = {
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Income Total',
		type: 'programProject'
	};
	incomeLines.forEach(rl => sumReportLines(totalIncomeRL, rl));

	const totalExpenseRL = {
		actual: 0,
		approvedBudget: 0,
		processedBudget: 0,
		processedVsApproved: 0,
		processedVsApprovedPercent: 0,
		label: 'Expense Total',
		type: 'programProject'
	};
	expenseLines.forEach(rl => sumReportLines(totalExpenseRL, rl));
	const totalNetIncome = _getCopy(totalIncomeRL);
	totalNetIncome.label = 'Total Net Income from Operations';
	subtractReportLines(totalNetIncome, totalExpenseRL);



	// null is empty row
	reportLines = [...incomeLines, totalIncomeRL, null, ...expenseLines, totalExpenseRL, null, totalIncomeRL, totalExpenseRL, totalNetIncome];

	//console.log('incomeLines = ' + JSON.stringify(incomeLines));
	//console.log('reportLines = ' + JSON.stringify(reportLines));
	//console.log('FFTPLines = ' + JSON.stringify(FFTPLines));
	return reportLines;
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
			let sheetType = SHEET_TYPE[sheetName];
			let excelSheet = workbook.addWorksheet(sheetName, {views: [{state: "frozen", ySplit: 1, xSplit: 0}]});
			if (sheetType === 'summary') {
				addSummaryHeaderAndSetColumnWidth(excelSheet);
				addSummaryReportLines(excelSheet, lines);
			} else if (sheetType === 'pairs') {

			} else {
				addSummaryHeaderAndSetColumnWidth(excelSheet);
				addSummaryReportLines(excelSheet, lines);
			}
		});

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

const getSummaryAndSimpleHeaderParams = () => {
	const previousBY = _this.selectedBY - 1;
	const nextBY = +_this.selectedBY + 1;
	const summaryHeaders = [
		{title: 'Type', width: 17},
		{title: 'Label', width: 50},
		{title: `${previousBY} Actual`, width: 15},
		{title: `${_this.selectedBY} Approved Budgeted`, width: 22},
		{title: `${nextBY} Proposed Budgeted`, width: 22},
		{title: `Proposed FY${nextBY} vs Approved FY${_this.selectedBY} ($)`, width: 32},
		{title: `Proposed FY${nextBY} vs Approved FY${_this.selectedBY} (%)`, width: 32}
	];
	return summaryHeaders;
};

const addSummaryHeaderAndSetColumnWidth = (sheet) => {
	try {
		const headerRow = sheet.getRow(1);
		getSummaryAndSimpleHeaderParams().forEach((h, i) => {
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

const SUMMARY_FIELD_ORDER = ['incomeStatementGroup', 'label', 'actual', 'approvedBudget', 'processedBudget', 'processedVsApproved', 'processedVsApprovedPercent'];

const addSummaryReportLines = (sheet, lines) => {
	try {
		let rowPosition = 2;
		let rowFill, rowFont;
		lines.forEach(line => {
			if (!line) {
				rowPosition++;
				return null;
			}
			const excelRow = sheet.getRow(rowPosition++);
			rowFill = getReportLineFill(line.type);
			rowFont = getReportLineFont(line.type);
			SUMMARY_FIELD_ORDER.forEach((f, i) => {
				const cell = excelRow.getCell(i + 1);
				_setCell(cell, line[f], rowFill, rowFont, null, null, SIMPLE_BORDERS);
				if (['actual', 'approvedBudget', 'processedBudget', 'processedVsApproved'].includes(f)) cell.numFmt = CURRENCY_FMT;
				if (f === 'processedVsApprovedPercent') cell.numFmt = PERCENT_FMT;
			});
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