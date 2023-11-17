({
	helpGetInitialSO: function(cmp) {
		let _this = this;

		function callback(cmp, resp) {
			try {
				let allParams = resp.getReturnValue();
				cmp.set('v.lockYear', allParams.fy);
				cmp.set('v.lockMonth', allParams.periods[0]['value']);
				_this.helpSetLockPeriod(cmp);
				_this.helpApplyLockSettings(cmp);
				if(allParams.baseYears.length === 0) cmp.set("v.disableUpdate", true);
			} catch (e) {
				alert(e);
			}
		}

		_CBRequest(cmp, "c.getParametersSOServer", null, "v.selectOptions", callback, null, 'Failed to get Select Options', false);
	},
	helpSetLockPeriod: function(cmp) {
		function callback(cmp, response){
			let resp = response.getReturnValue();
			cmp.set('v.lockMonth', resp);
			cmp.set('v.lockIndicator', resp);
		}
		_CBRequest(
			cmp,
			'c.getLockedPeriodServer',
			{
				'year' : cmp.get('v.lockYear')
			},
			null,
			callback,
			null,
			null,
			true
		);
	},
	helpApplyLockSettings: function(cmp) {
		function callback(cmp, response){
			let lockSetts = JSON.parse(response.getReturnValue());
			let selectOpts = cmp.get('v.selectOptions');
			let BPer = cmp.get('v.BPeriod');
			let perSetted = false;
			for(let i = 0; i< selectOpts.periods.length; i++){
				selectOpts.periods[i].disabled = false;
				let key = selectOpts.periods[i].value;
				if( lockSetts.hasOwnProperty(key)){
					let lastUpdateDate = new Date(lockSetts[key]).getTime() + 5 * 60000;
					selectOpts.periods[i].disabled = currTime < lastUpdateDate;
				}
				if(!perSetted && !selectOpts.periods[i].disabled){
					BPer = selectOpts.periods[i].value;
					perSetted = true;
				}
			}
			cmp.set('v.selectOptions', selectOpts);
			cmp.set('v.BPeriod', BPer);
		}
		_CBRequest(
			cmp,
			'c.getBLockSettings',
			null,
			null,
			callback,
			null,
			null,
			true
		);
	},
	helpSetLockedPeriodSO: function(cmp) {
		const _this = this;
		function callback(cmp, response){
			let resp = response.getReturnValue();
			let opts = cmp.get('v.selectOptions');
			opts.lockPeriods = resp;
			cmp.set('v.selectOptions', opts);
			_this.helpSetLockPeriod(cmp);
		}
		_CBRequest(
			cmp,
			'c.getPeriodsSOServer',
			{
				'year' : cmp.get('v.lockYear')
			},
			null,
			callback,
			null,
			null,
			true
		);
	},
	helpLockBudgetPeriods: function(cmp) {
		const lockedYear = cmp.get('v.lockYear');
		const lockedMonth = cmp.get('v.lockMonth');
		const sucMessage = lockedMonth === 'none' ? 'All Periods for BY' + lockedYear + ' unlocked' : 'Periods from  ' + lockedYear + '/01 ' + (parseInt(lockedYear) - 1) + ' till ' + lockedMonth + ' locked';
		function callback(cmp, response){
			if(response.getState() === 'SUCCESS') cmp.set('v.lockIndicator', lockedMonth);
		}
		_CBRequest(
			cmp,
			'c.lockBPeriodsTillServer',
			{
				'year' : lockedYear,
				'period' : lockedMonth
			},
			null,
			callback,
			sucMessage,
			'Error',
			true
		);
	},
	helpHandleBLockMenu: function(cmp, value) {
		switch (value) {
			case 'redirectToApexJobs':
				let win = window.open('/apexpages/setup/listAsyncApexJobs.apexp', '_blank');
				win.focus();
				break;
			default:
		}
	},
	helpRunBudgetDataFromStagersGeneration: function(cmp) {
		_CBRequest(
			cmp,
			'c.runBudgetDataGeneration',
			null,
			null,
			null,
			'Budget Generation started',
			'Failed to start Budget Data Generation',
			true
		);
	}
});