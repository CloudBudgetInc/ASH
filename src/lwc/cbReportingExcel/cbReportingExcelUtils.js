import {_message} from 'c/cbUtils';

const sumReportLines = (baseRL, currentRL, takeIntoAccountIncomeIsNegative) => {
	try {
		if (!baseRL) throw Error('Base line is null');
		if (!currentRL) throw Error('Current line is null');
		if (takeIntoAccountIncomeIsNegative && currentRL.incomeStatementGroup !== 'Income') {
			baseRL.actual -= parseFloat(currentRL.actual);
			baseRL.approvedBudget -= parseFloat(currentRL.approvedBudget);
			baseRL.processedBudget -= parseFloat(currentRL.processedBudget);
		} else {
			baseRL.actual += parseFloat(currentRL.actual);
			baseRL.approvedBudget += parseFloat(currentRL.approvedBudget);
			baseRL.processedBudget += parseFloat(currentRL.processedBudget);
		}
		normalizeRL(baseRL);
	} catch (e) {
		_message('error', 'Sum Report Lines Error : baseLine: ' + JSON.stringify(baseRL) + ' : currentLine: ' + JSON.stringify(currentRL) + ' => ' + e);
	}
};

const subtractReportLines = (baseRL, currentRL) => {
	try {
		baseRL.actual -= parseFloat(currentRL.actual);
		baseRL.approvedBudget -= parseFloat(currentRL.approvedBudget);
		baseRL.processedBudget -= parseFloat(currentRL.processedBudget);
		normalizeRL(baseRL);
	} catch (e) {
		_message('error', 'Subtract Report Lines Error : ' + e);
	}
};

const normalizeRL = (rl) => {
	try {
		rl.actual = round(rl.actual);
		rl.approvedBudget = round(rl.approvedBudget);
		rl.processedBudget = round(rl.processedBudget);
	} catch (e) {
		_message('error', 'Normalize RL Error ' + e);
	}
};

const calculateDifference = (reportLines) => {
	try {
		reportLines.forEach(rl => {
			try {
				rl.processedVsApproved = rl.processedBudget - rl.approvedBudget;
				rl.processedVsApprovedPercent = rl.approvedBudget === 0 ? 0 : (rl.processedVsApproved / rl.approvedBudget) * 100;
			} catch (e) {
				_message('error', 'Calculate Difference Error ' + e);
			}
		});
		return reportLines;
	} catch (e) {
		_message('error', 'Calculate Difference Error ' + e);
	}
};

const round = (n) => Number(n.toFixed(2));

export {sumReportLines, subtractReportLines, calculateDifference, round}