({
	setData: function(cmp, evt, h) {
		let row = cmp.get('v.row');
		let oldRow = cmp.get('v.oldRow');
		let disableOption = cmp.get('v.row.accT') === undefined || cmp.get('v.row.accountST') === undefined;
		cmp.set('v.localEditDisabled', disableOption);
		if(row.key === undefined) cmp.set('v.subRows', []);
		let oldKey = null;
		let subRows = cmp.get('v.subRows');
		if(subRows.length > 0){
			oldKey = subRows[0].text10;
		}
		if(oldRow === null){
			cmp.set('v.oldRow', JSON.parse(JSON.stringify(row)));
		}
		if(!disableOption && (subRows.length === 0 || oldKey === null)){
			cmp.set('v.subRows', []);
			cmp.set('v.allSubRows', []);
			cmp.set('v.isSubRowsEmpty', true);
			cmp.set('v.showSpinner', true);
			h.helpGetExistSubLines(cmp);
		}
	},

	addNewSubLine: function(cmp, evt, h) {
		h.helpAddNewSubLine(cmp);
	},

	saveSubLines: function(cmp, evt, h) {
		let status = 'f';
		let subLines = cmp.get('v.subRows');
		if(subLines.length > 0){
			if(h.validateSubLines(cmp)) {
				h.helpCalculateParentRowTotals(cmp, subLines);
				h.helpSaveSubLines(cmp);
				status = 't';
			}
		}else{
			if(cmp.get('v.localEditDisabled')){
				_CBMessages.fireWarningMessage('To save the added items, save the budget.', null);
			}
			h.helpCalculateParentRowTotals(cmp, subLines);
			status = 't';
		}
		return status;
	},

	resetOldRow: function(cmp, evt, h) {
		cmp.set('v.oldRow', null);
	},

	deleteSubLine: function(cmp, evt, h) {
		if (!confirm(_TEXT.APPS.DELETE_ROW_CONFIRM)) return;
		let rowKey = evt.getSource().get('v.value');
		h.helpDeleteSubLine(cmp, rowKey);
		cmp.set('v.disableCloseButton', true);
	},

	calculateTotals: function(cmp, evt, h) {
		h.helpCalculateTotals(cmp);
	},

	handleInputOnBlur: function(cmp, evt, h) {
		evt.getSource().set('v.value', parseFloat(evt.getSource().get('v.value')).toFixed(2));
		evt.getSource().reportValidity();
		h.helpCalculateTotals(cmp);
	},

	descriptionHandler: function (cmp, evt, h){
		let showStatus = cmp.get('v.showDescrModal');
		let subRows = cmp.get('v.subRows');
		let i = evt.currentTarget.className.replace(' slds-p-around_none','');
		cmp.set('v.subRowIndex', i);
		let descr = subRows[i].description;
		if(!showStatus && descr.length > 130){
			cmp.set('v.descrValue', descr);
			cmp.set('v.showDescrModal', true);
		}
	},

	closeDescriptionModal: function (cmp, evt, h){
		let subRows = cmp.get('v.subRows');
		let subRowIndex = cmp.get('v.subRowIndex');
		subRows[subRowIndex].description = cmp.get('v.descrValue');
		cmp.set('v.subRows', subRows);
		cmp.set('v.showDescrModal', false);
		cmp.set('v.descrValue', '');
	},

	spreadAmount: function(cmp, evt, h) {
		let rowKey = evt.getSource().get('v.value');
		let subRows = cmp.get('v.subRows');
		for(let i=0; i < subRows.length; i++){
			if(subRows[i].key === rowKey){
				subRows[i].rowValues[3].v = subRows[i].rowValues[2].v = subRows[i].rowValues[1].v = parseFloat(subRows[i].rowValues[0].v);
				break;
			}
		}
		cmp.set('v.subRows', subRows);
		h.helpCalculateTotals(cmp);
	},

	splitAmount: function(cmp, evt, h) {
		let rowKey = evt.getSource().get('v.value');
		let subRows = cmp.get('v.subRows');
		for(let i=0; i < subRows.length; i++){
			if(subRows[i].key === rowKey){
				let srValue = (parseFloat(subRows[i].rowValues[0].v)/4).toFixed(2);
				subRows[i].rowValues[3].v = subRows[i].rowValues[2].v = subRows[i].rowValues[1].v = subRows[i].rowValues[0].v = srValue;
				break;
			}
		}
		cmp.set('v.subRows', subRows);
		h.helpCalculateTotals(cmp);
	},

	selectAllAmount: function(cmp, evt, h) {
		let input = evt.getSource();
		input.set("v.selectionStart", 0);
		input.set("v.selectionEnd"  , 999);
	}

});