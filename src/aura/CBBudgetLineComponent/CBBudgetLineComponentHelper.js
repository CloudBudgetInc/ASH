({
	helpGetExistSubLines: function(cmp) {
		cmp.set('v.disableApplyButton', true);
		let _this = this;
		let subRows = cmp.get('v.subRows');
		let row = cmp.get('v.row');
		let budgetAppId = cmp.get('v.row.app');

		function callback(cmp, response){
			let allSubRows = response.getReturnValue();
			if(allSubRows.length > 0){
				_this.arrayToObjects(allSubRows, cmp);
				let newAllSubRows = [];
				for(let i = 0 ; i < allSubRows.length; i++){
					if(allSubRows[i].text10 === row.key){
						subRows.push(allSubRows[i]);
					}else{
						newAllSubRows.push(allSubRows[i]);
					}
				}
				cmp.set('v.subRows', subRows);
				cmp.set('v.allSubRows', newAllSubRows);

			}
			cmp.set('v.disableApplyButton', false);
			cmp.set('v.showSpinner', false);

			console.group('DEBUG');
			console.log(cmp.get('v.localEditDisabled'));
			console.log(cmp.get('v.disableApplyButton'));
			console.log(!cmp.get('v.adminAccess') && cmp.get('v.editDisabled'));
			console.log(cmp.get('v.app.cb4__Status__c') == 'Approved');
			console.log(cmp.get(' v.disableDeleteButton'));
			console.groupEnd();
		}

		_CBRequest(
			cmp,
			'c.getCBRowsFromServer',
			{
				'key' : row.key,
				'budgetAppId' : budgetAppId
			},
			null,
			callback,
			null,
			'Failed to get SubLines',
			false
		);

		cmp.set('v.isSubRowsEmpty', subRows.length === 0);
	},

	helpAddNewSubLine: function (cmp) {
		let row = cmp.get('v.row');
		let subRows = cmp.get('v.subRows');
		let newLine = JSON.parse(JSON.stringify(row));
		newLine.text10 = row.key;
		newLine.description = '';
		newLine.rowValues.forEach(rv=>{
			rv.v = 0;
		});
		newLine.key = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);// add unique index
		subRows.push(newLine);
		cmp.set('v.subRows', subRows);
		cmp.set('v.isSubRowsEmpty', false);
	},

	helpCalculateTotals: function(cmp) {
		let allRows = cmp.get('v.subRows');
		for(let i = 0; i < allRows.length; i++ ) {
			this.helpSumRow(allRows[i].rowValues);
		}
		cmp.set('v.subRows', allRows);
	},

	helpCalculateParentRowTotals: function(cmp, allRows) {
		let row = cmp.get('v.row');
		for(let c = 0; c < row.rowValues.length; c++){
			row.rowValues[c].v = 0;
		}
		for(let i = 0; i < allRows.length; i++){
			for(let j = 0; j < allRows[i].rowValues.length; j++){
				row.rowValues[j].v = (1 * row.rowValues[j].v) + (1 * allRows[i].rowValues[j].v);
			}
		}
		if(allRows.length === 0 || (row.rowValues[0].v === 0 && row.rowValues[1].v === 0 && row.rowValues[2].v === 0 && row.rowValues[3].v === 0)){
			row.rowValues[0].v = 0.01;
			_CBMessages.fireSuccessMessage('To save the line, a budget amount of 1 penny was created.', null);
		}
		row = this.objectsToArray(JSON.parse(JSON.stringify(row)));
		cmp.set('v.row', row);
	},

	helpSumRow: function (a) {
		try {
			let mt = 0; // money total
			let qt = 0; // quantity total
			let pt = 0; // price total
			for (let i = 0; i < a.length - 1; i++) {
				a[i].v = a[i].v === '' ? 0 : a[i].v;
				a[i].q = a[i].q === '' ? 0 : a[i].q;
				a[i].p = a[i].p === '' ? 0 : a[i].p;
				if (a[i].v !== '') mt += a[i].v - 0.0;
				if (a[i].q !== '') qt += a[i].q - 0.0;
				if (a[i].p !== '') pt += a[i].p - 0.0;
			}
			a[a.length - 1].v = mt;
			a[a.length - 1].q = qt;
			a[a.length - 1].p = pt;
			a[a.length - 1].t = 'disabled'; // t = type, total column disabling
		} catch (e) {
			alert(e);
		}
	},

	objectsToArray: function (rows) {
		for (let i = rows.length; i--;) {
			let m = []; // money
			let q = []; // quantity / hours
			let p = []; // price / rate
			let rv = rows[i].rowValues; // {v: 750, q: 1, p: 750}

			for (let j = 0; j < rv.length; j++) {
				m.push(rv[j].v);
				q.push(rv[j].q);
				p.push(rv[j].p);
			}
			rows[i].rowValues = m;
			rows[i].quantityValues = q; // quantity / hours
			rows[i].priceValues = p; // price / rate
		}
		return rows;
	},

	arrayToObjects: function (rows, cmp) {
		let splitRow = cmp.get("v.app.cb4__Decimal6__c");
		if (_isInvalid(splitRow)) splitRow = 0;
		const dis = 'disabled';

		for (let i = rows.length; i--;) {
			const inputType = rows[i].styleClass === 'calcRule' ? dis : false;
			let a = [];
			let rv = rows[i].rowValues;
			let pv = rows[i].priceValues;
			let qv = rows[i].quantityValues;
			for (let j = 0; j < rv.length; j++) a.push({
				v: rv[j],
				p: pv[j],
				q: qv[j],
				t: j < splitRow ? dis : inputType
			});

			delete rows[i].rowValues;
			delete rows[i].priceValues;
			delete rows[i].quantityValues;

			a[a.length - 1].t = dis; // last right total input is disabled
			rows[i].rowValues = a;
		}
		return rows;
	},

	helpSaveSubLines: function(cmp) {
		let budgetAppId = cmp.get('v.app.Id');
		let mainrow = cmp.get('v.row');
		let oldRow = cmp.get('v.oldRow');
		let rowKey = this.helpSetRowKey(mainrow, cmp.get('v.app'));
		let oldKey = null;
		let allSubRows = cmp.get('v.allSubRows');
		let rows = cmp.get('v.subRows');
		if(rows.length > 0){
			oldKey = rows[0].text10;
		}
		rows = rows.concat(allSubRows);
		rows = JSON.parse(JSON.stringify(rows));
		this.objectsToArray(rows);
		mainrow = JSON.parse(JSON.stringify(mainrow));
		oldRow = JSON.parse(JSON.stringify(oldRow));
		this.objectsToArray([mainrow]);
		this.objectsToArray([oldRow]);

		function callback(cmp, res){
			cmp.set('v.oldRow', null);
			cmp.set('v.subRows', []);
		}

		_CBRequest(
			cmp,
			'c.saveSubLinesServer',
			{
				'oldRow' : oldRow,
				'row'  : mainrow,
				'rows' : rows,
				'budgetAppId' : budgetAppId,
				'newKey' : rowKey,
				'oldKey' : oldKey
			},
			null,
			callback,
			'Data saved',
			'Failed to save Data',
			false
		);
	},

	helpSetRowKey: function(row, app) {
		function refineStringToId(s){
			return s.replaceAll(' ','').replaceAll(':','').replaceAll('&','');
		}
		return (app.Id === undefined ? '' : app.Id) +
			(row.lvl1Name === 'expense' || row.lvl1Name === 'income' ? row.lvl1Name.toLowerCase() : row.ie) +
			(row.title === undefined ? '' : refineStringToId(row.title).toLowerCase()) + // replace spaces
			(row.description === undefined ? '' : refineStringToId(row.description.slice(0, 100))) +
			(row.account === undefined ? '' : row.account) +
			(row.employeeId === undefined ? '' : row.employeeId) +
			//(row.rateId === undefined ? '' : row.rateId) +
			(row.dim6 === undefined ? '' : row.dim6) +
			(row.dim7 === undefined ? '' : row.dim7) +
			(row.dim8 === undefined ? '' : row.dim8) +
			(row.dim9 === undefined ? '' : row.dim9) +
			(row.dim10 === undefined ? '' : row.dim10);
	},

	helpDeleteSubLine: function(cmp, rowKey) {
		let row = cmp.get('v.row');
		row = JSON.parse(JSON.stringify(row));
		this.objectsToArray([row]);
		let subRows = cmp.get('v.subRows');
		let newSubRows = [];
		for(let i=0; i < subRows.length; i++){
			if(subRows[i].key !== rowKey){
				newSubRows.push(subRows[i]);
			}
		}
		cmp.set('v.subRows', newSubRows);
		cmp.set('v.isSubRowsEmpty', newSubRows.length === 0);
		function callback(cmp, res){
			cmp.set('v.showSpinner', false);
		}
		cmp.set('v.showSpinner', true);
		_CBRequest(
			cmp,
			'c.deleteSubLineServer',
			{
				'row'    : row,
				'rowKey' : rowKey
			},
			null,
			callback,
			'Data removed',
			null,
			false
		);
	},

	helpReturnRow: function(cmp) {
		let row = cmp.get('v.row');
		let compEvent = cmp.getEvent("compEvent");
		compEvent.setParams({row});
		compEvent.fire();
	},

	validateSubLines: function(cmp) {
		let validateState = true, zeroState = false;
		let subLines = cmp.get('v.subRows');

		for(let i = 0; i < subLines.length; i++){
			let descr = subLines[i].description;
			validateState = descr !== null && descr !== '' && descr !== undefined;
			zeroState = subLines[i].rowValues[0].v === 0 && subLines[i].rowValues[1].v === 0 && subLines[i].rowValues[2].v === 0 && subLines[i].rowValues[3].v === 0;
			if(zeroState) subLines[i].rowValues[0].v = 0.01;
		}
		cmp.set('v.subRows', subLines);
		if(!validateState){
			_CBMessages.fireWarningMessage('All description fields must be completed. SubLines with the same description will be merged into one.', null);
			return false;
		}
		if(zeroState){
			_CBMessages.fireWarningMessage('Sub Lines containing only 0 cannot be saved. The Budget Sub Line amount is automatically set to 0.01.', null);
			return false;
		}

		return validateState;
	}

});