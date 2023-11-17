import {LightningElement, track} from "lwc";
import exceljs from "@salesforce/resourceUrl/exceljs";
import {loadScript} from "lightning/platformResourceLoader";
import {_message, _parseServerError, _prompt, _setCell} from 'c/cbUtils';
import getReportDataServer from "@salesforce/apex/CBExcelReport.getReportDataServer";
import getNeededAnalyticsServer from "@salesforce/apex/CBExcelReport.getNeededAnalyticsServer";

import {calculateDifference, round, sumReportLines} from "./cbReportingExcelUtils"
import {setContext, manageDataAndGenerateFile} from "./cbReportingExcelExhibit"
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

	getReportingBalances = async () => {
		try {
			await getReportDataServer({selectedBY: parseInt(this.selectedBY), selectedCompany: this.selectedCompany})
				.then(reportingBalancesRaw => this.reportingBalancesRaw = reportingBalancesRaw)
				.catch(e => _parseServerError('Get Reporting Balances Error ', e))
		} catch (e) {
			_message('error', 'Get Reporting Balances Error : ' + e);
		}
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
			if(this.selectedTemplate === 'Budget Exhibit') {
				setContext(this);
				manageDataAndGenerateFile();
			}
			this.showSpinner = false;
		} catch (e) {
			_message('error', 'Download Data Error ' + e);
			this.showSpinner = false;
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


}