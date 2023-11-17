import {CURRENCY_FMT, PERCENT_FMT, PROGRAM_SUB_LINE_FONT, TOTAL_NET_LINE_FILL} from "./cbReportingExcelStyles"
import {_message, _setCell} from 'c/cbUtils';
import {calculateDifference, subtractReportLines, sumReportLines} from "./cbReportingExcelUtils"

/**
 * Specially for the Main sheet Hematology-Focus Fellowship Training Program (460) lines must be moved to the bottom of the list
 */
const moveHFFTPtoBottom = (reportLines) => {
	try {
		let updatedReportLines = [];
		let HFFTPReportLines = [];
		reportLines.forEach(rl => {
			if (rl.label === 'Total Net Income') return null;
			if (rl.programProject && rl.programProject.includes('(460)')) {
				rl.isHFFTP = true;
				HFFTPReportLines.push(rl);
			} else {
				updatedReportLines.push(rl);
			}
		});
		return [...updatedReportLines, ...HFFTPReportLines];
	} catch (e) {
		_message('error', 'Move HFFTP lines to bottom error ' + e);
	}
};


const addSpecialTableToMainSheet = (sheet, reportLines) => {
	try {
		const specialReportReportLines = {}; // key is 'Income Subtotal' or 'Program Expense Subtotal' or 'Salary and Overhead Subtotal'
		let HFFTPReportLine; //programProject
		reportLines.forEach(rl => {
			if (rl.type !== 'incomeStatementGroup') return null;
			if (rl.isHFFTP) HFFTPReportLine = rl;

			let line = specialReportReportLines[rl.label];
			if (!line) {
				line = {
					label: rl.label,
					actual: 0,
					approvedBudget: 0,
					processedBudget: 0,
					processedVsApproved: 0,
					processedVsApprovedPercent: 0,
				};
				specialReportReportLines[rl.label] = line;
			}
			line.actual += +rl.actual;
			line.approvedBudget += +rl.approvedBudget;
			line.processedBudget += +rl.processedBudget;
		});


		// LINES
		const totalIncomeLine = specialReportReportLines['Income Subtotal']; // using twice
		const totalExpenseLineNOHFFTP = {
			label: 'Expense',
			actual: 0,
			approvedBudget: 0,
			processedBudget: 0,
			processedVsApproved: 0,
			processedVsApprovedPercent: 0,
		};
		const totalNetIncomeLineNOHFFTP = {
			label: 'Net Income',
			actual: 0,
			approvedBudget: 0,
			processedBudget: 0,
			processedVsApproved: 0,
			processedVsApprovedPercent: 0,
		};
		// TOTAL INCOME LINE IS UPPER
		const totalProgramExpenseLine = specialReportReportLines['Program Expense Subtotal'];
		const totalSalaryAndOverheadLine = specialReportReportLines['Salary and Overhead Subtotal'];
		const totalExpenseLineWithHFFTP = {
			label: 'Total Expense from Reserves (HFFTP) + Operations',
			actual: 0,
			approvedBudget: 0,
			processedBudget: 0,
			processedVsApproved: 0,
			processedVsApprovedPercent: 0,
		};
		const totalNetIncomeWithHFFTP = {
			label: 'Net Income From Reserves + Operations',
			actual: 0,
			approvedBudget: 0,
			processedBudget: 0,
			processedVsApproved: 0,
			processedVsApprovedPercent: 0,
		};

		console.log('HFFTPReportLine:' + JSON.stringify(HFFTPReportLine));
		console.log('totalIncomeLine:' + JSON.stringify(totalIncomeLine));
		console.log('totalExpenseLineNOHFFTP:' + JSON.stringify(totalExpenseLineNOHFFTP));
		console.log('totalNetIncomeLineNOHFFTP:' + JSON.stringify(totalNetIncomeLineNOHFFTP));
		console.log('totalProgramExpenseLine:' + JSON.stringify(totalProgramExpenseLine));
		console.log('totalSalaryAndOverheadLine:' + JSON.stringify(totalSalaryAndOverheadLine));
		console.log('totalExpenseLineWithHFFTP:' + JSON.stringify(totalExpenseLineWithHFFTP));
		console.log('totalNetIncomeWithHFFTP:' + JSON.stringify(totalNetIncomeWithHFFTP));

		sumReportLines(totalExpenseLineNOHFFTP, totalProgramExpenseLine);
		sumReportLines(totalExpenseLineNOHFFTP, totalSalaryAndOverheadLine);
		if (HFFTPReportLine) subtractReportLines(totalExpenseLineNOHFFTP, HFFTPReportLine);

		sumReportLines(totalNetIncomeLineNOHFFTP, totalIncomeLine);
		subtractReportLines(totalNetIncomeLineNOHFFTP, totalExpenseLineNOHFFTP);

		sumReportLines(totalExpenseLineWithHFFTP, totalProgramExpenseLine);
		sumReportLines(totalExpenseLineWithHFFTP, totalSalaryAndOverheadLine);

		sumReportLines(totalNetIncomeWithHFFTP, totalIncomeLine);
		subtractReportLines(totalNetIncomeWithHFFTP, totalExpenseLineWithHFFTP);

		calculateDifference([totalIncomeLine, totalExpenseLineNOHFFTP, totalNetIncomeLineNOHFFTP, totalProgramExpenseLine, totalSalaryAndOverheadLine, totalExpenseLineWithHFFTP, totalNetIncomeWithHFFTP]);

		let startRowPosition = sheet.rowCount + 2;

		/** THE FIRST TABLE */
		[totalIncomeLine, totalExpenseLineNOHFFTP, totalNetIncomeLineNOHFFTP].forEach(line => {
			try {
				const row = sheet.getRow(startRowPosition++);
				const labelCell = row.getCell(5);
				const actualCell = row.getCell(6);
				const approvedBudgetCell = row.getCell(7);
				const processedBudgetCell = row.getCell(8);
				const processedVsApprovedCell = row.getCell(9);
				const processedVsApprovedPercentCell = row.getCell(10);
				const processedVsApproved = line.processedBudget - line.approvedBudget;
				const processedVsApprovedPercent = line.approvedBudget === 0 ? 0 : (line.processedVsApproved / line.approvedBudget) * 100;
				const textLabel = 'Total ' + line.label.replace('Subtotal', '') + ' from Operations';
				_setCell(labelCell, textLabel, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT);
				_setCell(actualCell, line.actual, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, CURRENCY_FMT);
				_setCell(approvedBudgetCell, line.approvedBudget, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, CURRENCY_FMT);
				_setCell(processedBudgetCell, line.processedBudget, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, CURRENCY_FMT);
				_setCell(processedVsApprovedCell, processedVsApproved, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, CURRENCY_FMT);
				_setCell(processedVsApprovedPercentCell, processedVsApprovedPercent, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, PERCENT_FMT);
			} catch (e) {
				_message('error', 'Populate Special Table Error ' + e);
			}
		});
		/** THE FIRST TABLE */
		startRowPosition++;
		/** THE SECOND TABLE */
		[totalIncomeLine, totalProgramExpenseLine, totalSalaryAndOverheadLine, totalExpenseLineWithHFFTP, totalNetIncomeWithHFFTP].forEach(line => {
			try {
				const row = sheet.getRow(startRowPosition++);
				const labelCell = row.getCell(5);
				const actualCell = row.getCell(6);
				const approvedBudgetCell = row.getCell(7);
				const processedBudgetCell = row.getCell(8);
				const processedVsApprovedCell = row.getCell(9);
				const processedVsApprovedPercentCell = row.getCell(10);
				const processedVsApproved = line.processedBudget - line.approvedBudget;
				const processedVsApprovedPercent = line.approvedBudget === 0 ? 0 : (line.processedVsApproved / line.approvedBudget) * 100;
				const textLabel = 'Total ' + line.label.replace('Subtotal', '');
				_setCell(labelCell, textLabel, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT);
				_setCell(actualCell, line.actual, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, CURRENCY_FMT);
				_setCell(approvedBudgetCell, line.approvedBudget, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, CURRENCY_FMT);
				_setCell(processedBudgetCell, line.processedBudget, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, CURRENCY_FMT);
				_setCell(processedVsApprovedCell, processedVsApproved, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, CURRENCY_FMT);
				_setCell(processedVsApprovedPercentCell, processedVsApprovedPercent, TOTAL_NET_LINE_FILL, PROGRAM_SUB_LINE_FONT, PERCENT_FMT);
			} catch (e) {
				_message('error', 'Populate Special Table Error ' + e);
			}
		});
		/** THE SECOND TABLE */

	} catch (e) {
		_message('error', 'Add Special Table Error ' + e);
	}

};

export {addSpecialTableToMainSheet, moveHFFTPtoBottom}