import {LightningElement, track} from "lwc";
import exceljs from "@salesforce/resourceUrl/exceljs";
import {loadScript} from "lightning/platformResourceLoader";
import {_message, _parseServerError, _prompt, _setCell} from 'c/cbUtils';
import getReportDataServer from "@salesforce/apex/CBExcelReport.getReportDataServer";
import getNeededAnalyticsServer from "@salesforce/apex/CBExcelReport.getNeededAnalyticsServer";
import {addSpecialTableToMainSheet, moveHFFTPtoBottom} from "./cbReportingExcelSpecialTable"
import {calculateDifference, round, sumReportLines} from "./cbReportingExcelUtils"
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

/**
 * DOCUMENTATION FOR THIS SHIT: https://www.npmjs.com/package/write-excel-file
 */
export default class cbReportingExcel extends LightningElement {
	@track reportingBalancesRaw = [];// list of all reporting balances
	@track separatedReportingBalances = {};// reporting balances separated by Dimension 2, key is Dim2 Name
	@track showSpinner = false;// true if the spinner needed
	@track budgetYearSO = [];// list of available budget year
	@track companySO = [];// list of available budget year
	@track templateSO = [{label: 'Budget Exhibit', value: 'Budget Exhibit'}, {
		label: 'Treasury Report',
		value: 'Treasury Report'
	}];// list of available templates
	@track selectedBY;// selected Budget year
	@track selectedCompany;// selected Company
	@track selectedTemplate = 'Budget Exhibit';// selected Template

	librariesLoaded = false;
	@track reportGroupColumns = [];
	@track reportColumns = [];
	@track reportLines = [];
	@track logs = [];
	@track fileName = "ASH Budget Exhibit";
	description;

	renderedCallback() {
		if (this.librariesLoaded) return;
		this.librariesLoaded = true;
		Promise.all([loadScript(this, exceljs)]).catch(function (e) {
			_message(`error`, `BLME : Excel Backup load library ${e}`);
		});
	}

	///////////////NEW LIB SECTION BELOW///////////////

	connectedCallback() { // component initialization
		this.getNeededAnalytics();
	}

	getNeededAnalytics = () => {
		getNeededAnalyticsServer()
			.then(analyticMap => {
				try {
					const budgetYears = analyticMap.budgetYearSO;
					this.budgetYearSO = budgetYears.reduce((r, by) => {
						r.push({label: by, value: by});
						return r;
					}, []);
					this.selectedBY = budgetYears[0];

					const companies = analyticMap.companySO;
					this.companySO = companies.reduce((r, cmp) => {
						r.push({label: cmp, value: cmp});
						return r;
					}, []);
					this.selectedCompany = companies[0];

				} catch (e) {
					_message('error', 'Apply Budget Years Error : ', e);
				}
			})
			.catch(e => _parseServerError('Get Available Budget Years Error ', e))
	};

	handleChangeFilter = (event) => {
		this[event.target.name] = event.target.value;
	};

	downloadData = async () => {
		console.log('RUN');
		this.HEADER_PARAMS = undefined;
		this.showSpinner = true;
		try {
			await this.getReportingBalances();
			this.generateLogs();
			if (!this.reportingBalancesRaw || this.reportingBalancesRaw.length === 0) {
				_message('warning', 'No reporting balances. Please try another filter');
				this.showSpinner = false;
				return null;
			}
			console.log('DATA RECEIVED');
			//console.log(this.reportingBalancesRaw.length);
			//this.reportingBalancesRaw.forEach(rb => console.log(JSON.stringify(rb)));
			this.createDataSetsSeparatedByDimension1();
			this.convertReportingBalancesToReportLines();

			//console.log('SEP: ' + JSON.stringify(this.separatedReportingBalances));
			this.generateExcelFile();
			this.showSpinner = false;
		} catch (e) {
			_message('error', 'Download Data Error ' + e);
			this.showSpinner = false;
		}
	};

	getReportingBalances = async () => {
		try {
			await getReportDataServer({selectedBY: parseInt(this.selectedBY), selectedCompany: this.selectedCompany})
				.then(reportingBalancesRaw => this.reportingBalancesRaw = reportingBalancesRaw)
				.catch(e => _parseServerError('Get Reporting Balances Error ', e))
		} catch (e) {
			_message('error', 'Get Reporting Balances Error : ' + e);
		}
	};

	generateLogs = () => {
		try {
			this.logs = [];
			if (!this.reportingBalancesRaw || this.reportingBalancesRaw.length === 0) {
				this.logs.push('No Reporting Lines');
				return null;
			}
			const logs = [];
			logs.push('Total number of reporting balances: ' + this.reportingBalancesRaw.length + '. Limit is 50k records');
			const logsObject = {};
			this.reportingBalancesRaw.forEach(rb => {
				const type = 'Revenue ' + rb.c2g__Type__c + ' (' + rb.Year__c + ')';
				const subtotal = rb.c2g__Type__c + ' (' + rb.Year__c + ') ' + rb.Income_Statement_Group__c;
				const value = rb.c2g__Type__c !== 'Actual' && rb.Income_Statement_Group__c === 'Income' ? +rb.c2g__DualValue__c * -1 : +rb.c2g__DualValue__c;

				let typeLog = logsObject[type];
				if (!typeLog) {
					typeLog = {type, number: 0, total: 0};
					logsObject[type] = typeLog;
				}
				typeLog.number++;
				typeLog.total += value;

				let subtotalLog = logsObject[subtotal];
				if (!subtotalLog) {
					subtotalLog = {type, number: 0, total: 0};
					logsObject[subtotal] = subtotalLog;
				}
				subtotalLog.number++;
				subtotalLog.total += value;
			});
			Object.keys(logsObject).forEach(type => {
				const typLog = logsObject[type];
				logs.push('Type: ' + type + '. Number of records: ' + typLog.number + '. Total: $' + round(typLog.total));
			});
			this.logs = logs;
		} catch (e) {
			_message('error', 'Get logs error : ' + e);
		}
	};

	/**
	 * Method separates reporting balances by Dimension 2 Name and put extra lines to default list
	 */
	createDataSetsSeparatedByDimension1 = () => {
		try {
			const firstSheetName = 'Main';
			const RBWithoutDimension2SheetName = 'Default';
			this.separatedReportingBalances = this.reportingBalancesRaw.reduce((result, rb) => {
				try {
					let mainSheetList = result[firstSheetName];
					if (!mainSheetList) {
						mainSheetList = [];
						result[firstSheetName] = mainSheetList;
					}

					let dim2Name = rb.c2g__Dimension1__r?.Name;
					if (!dim2Name) dim2Name = RBWithoutDimension2SheetName;
					let dim2List = result[dim2Name];
					if (!dim2List) {
						dim2List = [];
						result[dim2Name] = dim2List;
					}

					mainSheetList.push(rb);
					dim2List.push(rb);
					return result;
				} catch (e) {
					_message('error', 'Separate Data by Dimension 2 Iterating Error: ' + e);
				}
			}, {});
		} catch (e) {
			_message('error', 'Separate Data by Dimension 2 Error: ' + e);
		}
	};

	convertReportingBalancesToReportLines = () => {
		Object.keys(this.separatedReportingBalances).forEach(key => {
			let reportingBalances = this.separatedReportingBalances[key];
			let reportLines = this.getReportLinesFromReportingBalances(reportingBalances);
			reportLines = this.addSubTotalLines(reportLines);
			if (key === 'Main') reportLines = moveHFFTPtoBottom(reportLines);
			reportLines = calculateDifference(reportLines);
			this.separatedReportingBalances[key] = reportLines;
		});
	};

	getReportLinesFromReportingBalances = (RBList) => {
		const reportLinesMap = {}; // key is dim2 Id and account Id
		RBList.forEach(rb => {
			try {
				const lineKey = rb.c2g__Dimension2__c + rb.c2g__Dimension3__c + rb.Income_Statement_Group__c + rb.c2g__GeneralLedgerAccount__c;
				let reportLine = reportLinesMap[lineKey];
				if (!reportLine) {
					reportLine = this.getNewReportLine(rb, lineKey);
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
						if (rb.Year__c === this.selectedBY) {
							reportLine.approvedBudget += parseFloat(rb.c2g__DualValue__c);
						} else {
							reportLine.processedBudget += parseFloat(rb.c2g__DualValue__c);
						}
					}
				}
			} catch (e) {
				_message('error', 'Get RL from RB Error : ' + e);
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
	getNewReportLine = (rb, lineKey) => {
		return {
			lineKey,
			program: rb.c2g__Dimension2__r?.Name,
			programProject: rb.c2g__Dimension2__r?.Name + '-' + rb.c2g__Dimension3__r?.Name,
			incomeStatementGroup: rb.Income_Statement_Group__c,
			generalLedgerName: rb.c2g__GeneralLedgerAccount__r?.Name,
			accountSubAccount: rb.Account_Subaccount__c,
			label: '',
			actual: 0,
			approvedBudget: 0, // selected BY
			processedBudget: 0, // next BY
			processedVsApproved: 0,
			processedVsApprovedPercent: 0,
		};
	};

	addSubTotalLines = (reportLines) => {
		try {
			const updatedReportLines = [];
			let incomeStatementGroup; // light total
			let incomeStatementSubLine;

			let programProject; // medium total
			let programProjectSubLine;

			let program; // hard total
			let programSubLine;

			const totalNetLine = {
				type: 'totalNet',
				actual: 0,
				approvedBudget: 0,
				processedBudget: 0,
				processedVsApproved: 0,
				processedVsApprovedPercent: 0,
				label: 'Total Net Income'
			};

			reportLines.forEach((rl, i) => {
				try {
					if (i === 0) { // first line

						incomeStatementGroup = rl.incomeStatementGroup + rl.programProject;
						incomeStatementSubLine = this.getNewIncomeStatementSubLine(rl);

						programProject = rl.programProject;
						programProjectSubLine = this.getNewProgramProjectSubLine(rl);

						program = rl.program;
						programSubLine = this.getNewProgramSubLine(rl);

						sumReportLines(incomeStatementSubLine, rl);
						sumReportLines(programProjectSubLine, rl, true);
						sumReportLines(programSubLine, rl, true);
						sumReportLines(totalNetLine, rl, true);

						updatedReportLines.push(rl);
						return null;
					}
					if (incomeStatementGroup !== rl.incomeStatementGroup + rl.programProject) { //flush incomeStatementSubLine
						updatedReportLines.push(incomeStatementSubLine);
						incomeStatementGroup = rl.incomeStatementGroup + rl.programProject;
						incomeStatementSubLine = this.getNewIncomeStatementSubLine(rl);
					}

					if (programProject !== rl.programProject) { //flush programProjectSubLine
						updatedReportLines.push(programProjectSubLine);
						programProject = rl.programProject;
						programProjectSubLine = this.getNewProgramProjectSubLine(rl);
					}

					if (program !== rl.program) { //flush programSubLine
						updatedReportLines.push(programSubLine);
						program = rl.program;
						programSubLine = this.getNewProgramSubLine(rl);
					}

					sumReportLines(incomeStatementSubLine, rl);
					sumReportLines(programProjectSubLine, rl, true);
					sumReportLines(programSubLine, rl, true);
					sumReportLines(totalNetLine, rl, true);

					updatedReportLines.push(rl);
				} catch (e) {
					_message('error', 'Add Subtotal Lines Error ' + e);
				}
			});
			if (incomeStatementSubLine) updatedReportLines.push(incomeStatementSubLine); // flush the last subline
			if (programProjectSubLine) updatedReportLines.push(programProjectSubLine); // flush the last programProjectSubLine
			if (programSubLine) updatedReportLines.push(programSubLine); // flush the last programProjectSubLine
			updatedReportLines.push(totalNetLine); // flush totalNetLine
			return updatedReportLines;
		} catch (e) {
			_message('error', 'Add SubtotalLines Error ' + e);
		}
	};

	replaceZeroWithEmptyCell = rl => {
		if (rl.actual === 0) rl.actual = '';
		if (rl.approvedBudget === 0) rl.approvedBudget = '';
		if (rl.processedVsApproved === 0) rl.processedVsApproved = '';
		if (rl.processedVsApprovedPercent === 0) rl.processedVsApprovedPercent = '';
	};


	roundToTwoDecimals = (num) => {
		return Math.round(num * 100) / 100;
	};

	getNewIncomeStatementSubLine = (rl) => {
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

	getNewProgramProjectSubLine = (rl) => {
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

	getNewProgramSubLine = (rl) => {
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
	generateExcelFile = async () => {
		try {

			this.showSpinner = true;
			let fileName = `${this.fileName} ${this.selectedBY}`;
			fileName = await _prompt("Type the file name", fileName, 'File Name');
			if (!fileName || fileName.length < 1) {
				this.showSpinner = false;
				return;
			}
			let workbook = new ExcelJS.Workbook();

			//Object.keys(this.separatedReportingBalances).forEach(name => console.log('SHEET NAME : ' + name));
			Object.keys(this.separatedReportingBalances).forEach(sheetName => {
				const lines = this.separatedReportingBalances[sheetName];
				let dim1Sheet = workbook.addWorksheet(sheetName, {views: [{state: "frozen", ySplit: 1, xSplit: 0}]});
				this.addHeaderAndSetColumnWidth(dim1Sheet);
				this.addReportLines(dim1Sheet, lines);
			});

			addSpecialTableToMainSheet(workbook.getWorksheet('Main'), this.separatedReportingBalances['Main']);

			let data = await workbook.xlsx.writeBuffer();
			const blob = new Blob([data], {type: "application/octet-stream"});
			let downloadLink = document.createElement("a");
			downloadLink.href = window.URL.createObjectURL(blob);
			downloadLink.target = "_blank";
			downloadLink.download = fileName + ".xlsx";
			downloadLink.click();
			this.showSpinner = false;
		} catch (e) {
			_message("error", "Reporting Excel generateExcelFile error: " + e);
			this.showSpinner = false;
		}
	};

	HEADER_PARAMS;
	getHeaderParams = () => {
		if (!this.HEADER_PARAMS) {
			const previousBY = this.selectedBY - 1;
			const nextBY = +this.selectedBY + 1;
			this.HEADER_PARAMS = [
				{title: 'Program-Project', width: 50},
				{title: 'Income Statement Group', width: 35},
				{title: 'General Ledger Name', width: 35},
				{title: 'Account-Subaccount', width: 20},
				{title: 'Label', width: 47},
				{title: `${previousBY} Actual`, width: 15},
				{title: `${this.selectedBY} Approved Budgeted`, width: 22},
				{title: `${nextBY} Proposed Budgeted`, width: 22},
				{title: `Proposed FY${nextBY} vs Approved FY${this.selectedBY} ($)`, width: 32},
				{title: `Proposed FY${nextBY} vs Approved FY${this.selectedBY} (%)`, width: 32}
			];
		}
		return this.HEADER_PARAMS;
	};

	addHeaderAndSetColumnWidth = (sheet) => {
		try {
			const headerRow = sheet.getRow(1);
			this.getHeaderParams().forEach((h, i) => {
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

	FIELD_ORDER = ['programProject', 'incomeStatementGroup', 'generalLedgerName', 'accountSubAccount', 'label', 'actual', 'approvedBudget', 'processedBudget', 'processedVsApproved', 'processedVsApprovedPercent'];

	addReportLines = (sheet, lines) => {
		try {
			let rowPosition = 2;
			let rowFill, rowFont, previousLineWasProgramSubtotal, previousLineWasSimple;
			lines.forEach((line, i) => {
				if (previousLineWasProgramSubtotal) rowPosition++;
				const excelRow = sheet.getRow(rowPosition++);
				rowFill = this.getReportLineFill(line.type);
				rowFont = this.getReportLineFont(line.type);
				if (previousLineWasSimple) line.programProject = line.incomeStatementGroup = undefined;
				this.FIELD_ORDER.forEach((f, i) => {
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

	getReportLineFill = (type) => {
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
	getReportLineFont = (type) => {
		switch (type) {
			case 'program':
				return PROGRAM_SUB_LINE_FONT;
			case 'totalNet':
				return PROGRAM_SUB_LINE_FONT;
			default:
				return undefined;
		}
	};
}