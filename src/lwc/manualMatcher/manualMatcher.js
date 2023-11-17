import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import bankStatementTransactions from '@salesforce/apex/ReconcilerController.bankStatementTransactions';
import generalLedgerTransactions from '@salesforce/apex/ReconcilerController.generalLedgerTransactions';
import handleMatch from '@salesforce/apex/ReconcilerController.handleMatch';
import clearData from '@salesforce/apex/ReconcilerController.clear'; 

export default class Reconcile extends LightningElement {

    @api recordId;
    loading = false;
    showModal = false;
    reconciled = true;
    isMatching = false; // [CM5]: hide the 'difference' indicator as needed.
    buttondisabled = true;
    buttonLabel = 'Match';
    
    showStatement = true;
    statementLinkLabel = 'hide table';

    previousBANKselectedRows = [];
    difference = 0;
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    STATEMENTstartDate;
    STATEMENTendDate;
    STATEMENTTypeFilter = '';
    STATEMENTReferenceFilter;
    STATEMENTAmountFilter;
    STATEMENTrecordData = {};
    STATEMENTselectedRows = [];
    STATEMENThasRows = false;
    STATEMENTselectedTotal = 0;
    STATEMENTmatchStatus = 'All';
    STATEMENTcheckFilter = '';
    STATEMENTcolumns = [
        { label: 'Transaction Date', fieldName: 'Transaction_Date_Display__c', type: 'date', hideDefaultActions: true },
        { label: 'Check Number', fieldName: 'Addenda_1__c', type: 'text', hideDefaultActions: true },
        { label: 'Reference', fieldName: 'Reference__c', type: 'text', hideDefaultActions: true },
        { label: 'Type', fieldName: 'Type__c', type: 'text', fixedWidth: 300, hideDefaultActions: true },
        { label: 'Matched Status', fieldName: 'Match_Status__c', type: 'text', fixedWidth: 160, hideDefaultActions: true },
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency', fixedWidth: 160, hideDefaultActions: true },
        { label: 'Remaining Amount', fieldName: 'Remaining_Amount__c', type: 'currency', fixedWidth: 160, hideDefaultActions: true }
    ];
    STATEMENTmatchStatusOptions = [
        { label: 'All', value: 'All' },
        { label: 'Unmatched', value: 'Unmatched' },
        // { label: 'Matched', value: 'Matched' },
        { label: 'Partial Matched', value: 'Partial Matched' },
    ];
    STATEMENTTypeOptions = [
        { label: 'All', value: 'All' },
        { label: 'ACH', value: 'ACH' },        
        { label: 'Check', value: 'Check' },
    ];
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    LEDGERstartDate;
    LEDGERendDate;
    LEDGERAccountFilter;
    LEDGERTypeFilter = 'All';
    LEDGERReferenceFilter;
    LEDGERAmountFilter;
    LEDGERrecordData = {};
    LEDGERselectedRows = [];
    LEDGERhasRows = false;
    LEDGERselectedTotal = 0;
    LEDGERcolumns = [
        { label: 'Transaction Date', fieldName: 'Transaction_Date_Display__c', type: 'date', hideDefaultActions: true },
        { label: 'Account', fieldName: 'Account__c', type: 'text', hideDefaultActions: true },
        { label: 'Reference', fieldName: 'Reference__c', type: 'text', hideDefaultActions: true },
        { label: 'Type', fieldName: 'Transaction_Type__c', type: 'text', fixedWidth: 300, hideDefaultActions: true },
        { label: '', type: 'text', fixedWidth: 160, hideDefaultActions: true },
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency', fixedWidth: 160, hideDefaultActions: true },
        { label: '', type: 'text', fixedWidth: 160, hideDefaultActions: true }
    ];
    LEDGERTypeOptions = [
        { label: 'All', value: 'All' },
        { label: 'ACH', value: 'ACH' },  
        { label: 'Check', value: 'Check' },                
        { label: 'Domestic Wire', value: 'Domestic Wire' },
        { label: 'International Wire', value: 'International Wire' },
        { label: 'Manual Wire', value: 'Manual Wire' },
        { label: 'Journal', value: 'Journal' },
    ];
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Load data when the component is connected
    connectedCallback() {
        this.LoadAllData();
    }
    renderedCallback() {
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Load data for both STATEMENT and LEDGER sections
    LoadAllData() {
        this.buttondisabled = true;
        this.buttonLabel = 'Loading';
        this.loading = true; // Show loading spinner        
        this.LEDGERloadRecordData();
        this.STATEMENTloadRecordData();
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Clear filters and reload data
    handleReset() {
        console.log('Reset');
        this.isMatching = false;
        // Clear selected rows for the STATEMENT datatable
        const STATEMENTDataTable = this.template.querySelector('[data-table="STATEMENT"]');
        if (STATEMENTDataTable) {
            STATEMENTDataTable.selectedRows = [];
        }

        // Clear selected rows for the LEDGER datatable
        const LEDGERDataTable = this.template.querySelector('[data-table="LEDGER"]');
        if (LEDGERDataTable) {
            LEDGERDataTable.selectedRows = [];
        }
        // Reset STATEMENT filters
        //this.STATEMENTstartDate = null;
        //this.STATEMENTendDate = null;
        this.STATEMENTTypeFilter = '';
        this.STATEMENTReferenceFilter = '';
        this.STATEMENTAmountFilter = '';
        this.STATEMENTselectedRows = [];
        this.STATEMENTselectedTotal = 0;

        // Reset LEDGER filters
        //this.LEDGERstartDate = null;
        //this.LEDGERendDate = null;
        this.LEDGERAccountFilter = '';
        this.LEDGERTypeFilter = '';
        this.LEDGERReferenceFilter = '';
        this.LEDGERAmountFilter = '';
        this.LEDGERselectedRows = [];
        this.LEDGERselectedTotal = 0;

        this.difference = 0;

        this.STATEMENTmatchStatus = 'All';

        // Reset any other filters as needed
        this.reconciled = true;
        this.LoadAllData();
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    toggleStatementTable(event) {
        event.preventDefault();
        if(this.showStatement) {
            this.showStatement = false;
            this.statementLinkLabel = 'show table';
        } else {
            this.showStatement = true;
            this.statementLinkLabel = 'hide table';
        }
    }   
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Hide the modal
    hideModal() {
        this.showModal = false;
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Display the modal
    displayModal() {
        this.showModal = true;
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Calculate the difference
    //  [CM5]: Only showing an icon when at least one row is selected.
    calculateDifference() {        
        this.difference = this.STATEMENTselectedTotal.toFixed(2) - this.LEDGERselectedTotal.toFixed(2);
        console.log('difference',this.difference);
        console.log('STATEMENTselectedTotal',this.STATEMENTselectedTotal);
        console.log('LEDGERselectedTotal',this.LEDGERselectedTotal);

        if (this.STATEMENTselectedRows.length > 0 || this.LEDGERselectedRows.length > 0) {
            this.isMatching = true;            

            if (this.difference == 0) {
                this.reconciled = true;
            } else {
                this.reconciled = false;
            }
        } else {
            this.isMatching = false;
        }
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Bank Statement Transactions Functions
    */
    // Load STATEMENT record data
    STATEMENTloadRecordData() {

        bankStatementTransactions({
            recordId: this.recordId,
            startDate: this.STATEMENTstartDate,
            endDate: this.STATEMENTendDate,
            TypeFilter: this.STATEMENTTypeFilter,
            ReferenceFilter: this.STATEMENTReferenceFilter,
            AmountFilter: this.STATEMENTAmountFilter,
            strMatchStatus: this.STATEMENTmatchStatus,
            checkFilter: this.STATEMENTcheckFilter
        })
            .then(result => {
                if (result.length != 0) {
                    this.STATEMENTrecordData = result;
                    this.STATEMENThasRows = true;
                } else {
                    this.STATEMENThasRows = false;
                }
            })
            .catch(error => {
                console.error('Error loading STATEMENT record data:', error);
            })
            .finally(() => {
                this.STATEMENTloading = false; // Hide loading spinner
            });
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Handle STATEMENT filter input changes
    handleSTATEMENTInputChange(event) {
        // Extract the field name and value from the input event
        const fieldName = event.target.name;
        const fieldValue = event.target.value;

        // Update the corresponding property based on the field name
        if (fieldName === 'startDate') {
            this.STATEMENTstartDate = fieldValue;
        } else if (fieldName === 'endDate') {
            this.STATEMENTendDate = fieldValue;
        } else if (fieldName === 'ReferenceFilter') {
            this.STATEMENTReferenceFilter = fieldValue;
        } else if (fieldName === 'TypeFilter') {
            this.STATEMENTTypeFilter = fieldValue;
        } else if (fieldName === 'AmountFilter') {
            this.STATEMENTAmountFilter = fieldValue;
        } else if (fieldName === 'CheckFilter') {
            this.STATEMENTcheckFilter = fieldValue;
        }

        // Load STATEMENT data with updated filters
        this.STATEMENTloadRecordData();
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Handle STATEMENT row selection
    STATEMENThandleRowSelection(event) {

        this.STATEMENTselectedRows = event.detail.selectedRows;

        let totalAmount = 0;

        this.STATEMENTselectedRows.forEach(row => {            
            console.log(row.Remaining_Amount__c == null);            
            if (row.Remaining_Amount__c == null) {                
                totalAmount += row.Amount__c;
            } else {
                totalAmount += row.Remaining_Amount__c;
            }
            console.log('totalAmount', totalAmount);
        });

        this.STATEMENTselectedTotal = totalAmount;
        this.calculateDifference();
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    //    
    handleSTATEMENTMatchStatusChange(event) {

        this.STATEMENTmatchStatus = event.detail.value;
        // Call the STATEMENTloadRecordData method here to apply the filter
        this.STATEMENTloadRecordData();
    }
    //  [CM5] handle the dropdown for the Statement Type    
    handleSTATEMENTTypeChange(event) {

        this.STATEMENTTypeFilter = event.detail.value;
        // Call the STATEMENTloadRecordData method here to apply the filter
        this.STATEMENTloadRecordData();
    }
    handleLEDGERTypeChange(event) {

        this.LEDGERTypeFilter = event.detail.value;
        // Call the STATEMENTloadRecordData method here to apply the filter
        this.LEDGERloadRecordData();
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        General Ledger Transactions Functions
    */
    // Load LEDGER record data
    LEDGERloadRecordData() {

        generalLedgerTransactions({
            recordId: this.recordId,
            startDate: this.LEDGERstartDate,
            endDate: this.LEDGERendDate,
            TypeFilter: this.LEDGERTypeFilter,
            ReferenceFilter: this.LEDGERReferenceFilter,
            AccountFilter: this.LEDGERAccountFilter,
            AmountFilter: this.LEDGERAmountFilter
        })
            .then(result => {
                if (result.length != 0) {
                    this.LEDGERrecordData = result;
                    this.LEDGERhasRows = true;
                } else {
                    this.LEDGERhasRows = false;
                }
            })
            .catch(error => {
                console.error('Error loading LEDGER record data:', error);
            })
            .finally(() => {
                this.loading = false; // Hide loading spinner
                this.buttondisabled = false;
                this.buttonLabel = 'Match';
            });
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Handle LEDGER filter input changes
    LEDGERHandleInputChange(event) {
        // Extract the field name and value from the input event
        const fieldName = event.target.name;
        const fieldValue = event.target.value;

        // Update the corresponding property based on the field name
        if (fieldName === 'startDate') {
            this.LEDGERstartDate = fieldValue;
        } else if (fieldName === 'endDate') {
            this.LEDGERendDate = fieldValue;
        } else if (fieldName === 'AccountFilter') {
            this.LEDGERAccountFilter = fieldValue;
        } else if (fieldName === 'ReferenceFilter') {
            this.LEDGERReferenceFilter = fieldValue;
        } else if (fieldName === 'TypeFilter') {
            this.LEDGERTypeFilter = fieldValue;
        } else if (fieldName === 'AmountFilter') {
            this.LEDGERAmountFilter = fieldValue;
        }

        // Load LEDGER data with updated filters
        this.LEDGERloadRecordData();
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Handle LEDGER row selection
    LEDGERhandleRowSelection(event) {
        this.LEDGERselectedRows = event.detail.selectedRows;

        let totalAmount = 0;
        this.LEDGERselectedRows.forEach(row => {
            totalAmount += row.Amount__c;
        });

        this.LEDGERselectedTotal = totalAmount;
        this.calculateDifference();
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    // Separate function to check for matching
    checkMatch() {
        // Calculate the difference
        this.calculateDifference();

        if (this.difference !== 0) {
            // Display the modal for partial match
            this.displayModal();
        } else {
            // Continue with reconciliation
            this.handleMatch();
        }
    }
    // Handle the reconciliation process
    handleMatch() {        
        this.hideModal();
        this.loading = true;
        this.buttondisabled = true;
        this.buttonLabel = 'Matching';
        const selectedStatementRowIds = this.STATEMENTselectedRows.map(row => row.Id);
        const selectedBankTransactionRowIds = this.LEDGERselectedRows.map(row => row.Id);

        handleMatch({
            selectedStatementRowIds: selectedStatementRowIds,
            selectedBankTransactionRowIds: selectedBankTransactionRowIds,
            recordId: this.recordId
        })
        .then(result => {
                if (result == true) {
                    this.showToast('Success', 'Records Matched Successfully', 'success');
                    this.reconciled = true;
                    this.LEDGERselectedRows = [];   // add to clear checkboxes on match
                    this.STATEMENTselectedRows = [];    // add to clear checkboxes on match
                    this.handleReset();
                    this.LoadAllData();
                    this.isMatching = false;
                }
            })
            .catch(error => {
                // Handle any errors that occur
                this.showToast('Error', 'An error occurred while matching records', 'error');
            })
            .finally(() => {
                this.loading = false;
                this.buttondisabled = false;
                this.buttonLabel = 'Match';
            });
    }
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */

    handleClearData() {
        this.loading = true;
        this.buttondisabled = true;
        this.buttonLabel = 'Processing';
        clearData()
            .then(result => {
                this.showToast('Success', 'Data Cleared Successfully', 'success');
                this.handleReset();
                this.LoadAllData();
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred while clearing data', 'error');
            });
    }
    
    /*  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}