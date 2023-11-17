import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedEPTasks from '@salesforce/apex/CustomTaskListController.getRelatedEPTasks';
import { refreshApex } from '@salesforce/apex';

const columns = [
    {
        label: "Subject",
        fieldName: "Subject",
        hideDefaultActions: true,
        type: "button",
        typeAttributes: {
            label: { fieldName: "Subject" },
            name: "show_task_details",
            variant: "base",
        },
        sortable: true,
        wrapText: false
    },
    {
        label: "Due Date",
        fieldName: "ActivityDate",
        hideDefaultActions: true,
        type: "date-local",
        typeAttributes: {  
            month: 'numeric',  
            day: 'numeric',  
            year: 'numeric',  
        },
        sortable: true,
        wrapText: false
    },
    {
        label: "Completed Date",
        fieldName: "Completed_Date__c",
        hideDefaultActions: true,
        type: "date",
        typeAttributes: {
            month: "numeric",
            day: "numeric",
            year: "numeric"
        },
        sortable: true
    },
    {
        label: "Assigned To",
        fieldName: "OwnerName",
        hideDefaultActions: true,
        type: "button",
        typeAttributes: {
            label: { fieldName: "OwnerName" },
            value: { fieldName: "User" },
            name: "show_owner_details",
            title: "show_owner_details",
            variant: "base"
        },
        sortable: true,
        wrapText: false
    },
    {
        label: "Status",
        fieldName: "Status",
        hideDefaultActions: true,
        sortable: true,
        wrapText: false
    },
    {
        label: "Priority",
        fieldName: "Priority",
        hideDefaultActions: true,
        sortable: true,
        wrapText: false
    },
    {
        label: "Last Modified Date/Time",
        fieldName: "LastModifiedDate",
        hideDefaultActions: true,
        type: "date",
        typeAttributes: {  
            month: 'numeric',  
            day: 'numeric',  
            year: 'numeric',  
            hour: '2-digit',  
            minute: '2-digit',  
            hour12: true
        },
        sortable: true,
        wrapText: false
    },
];


export default class CustomEPRelatedTasks extends NavigationMixin(LightningElement) {
    @api recordId;
    @track tasksList;
    @track totalTasks = 0;
    @track refreshSuccess = false;
    columns = columns;
    sortDirection = 'asc';
    sortedBy = 'Subject';

    wiredResults;

    @wire(getRelatedEPTasks, {id: "$recordId"})
    fetchEPTasks(results) {
        this.wiredResults = results;
        const { data, error } = results;

        if (data) {
            // Owner.Name is part of a nested query. Datatable cannot access nested values so need to move it out.
            this.tasksList = data.map(record => 
                Object.assign( { "OwnerName": record.Owner.Name}, record )
            );

            this.totalTasks = data.length;
        } 
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;

        // temporary shallow copy of tasksList.
        let listCopy = JSON.parse(JSON.stringify(this.tasksList));

        listCopy.sort((task1, task2) => {
            // SAME value - do nothing.
            if (task1[this.sortedBy] === task2[this.sortedBy]) { return 0; }

            // Check if both have a value.
            if (task1[this.sortedBy] !== undefined && task2[this.sortedBy] !== undefined) {
                // DESC
                if (this.sortDirection === 'desc') {
                    return task1[this.sortedBy] > task2[this.sortedBy] ? -1 : 1;
                }

                // ASC
                return task1[this.sortedBy] < task2[this.sortedBy] ? -1 : 1;
            }
            
            // one of the tasks on comparison had an undefined value.
            // check if the first/current task has a value.
            // if so, keep at top. If not, push it to the bottom.
            return task1[this.sortedBy] !== undefined ? -1 : 1;
        });

        this.tasksList = listCopy;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        const rowData = JSON.parse(JSON.stringify(row));

        switch(action.name) {
            case "show_task_details":
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                      recordId: rowData.Id,
                      objectApiName: 'Task',
                      actionName: 'view'
                    }
                  });
                break;
            case "show_owner_details":
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                      recordId: rowData.OwnerId,
                      objectApiName: 'User',
                      actionName: 'view'
                    }
                  });
                break;
            default:
                break;
        }
    }

    handleDataRefresh() {
        this.refreshSuccess = false;

        refreshApex(this.wiredResults)
        .then(() => {
            this.refreshSuccess = true;
        });
    }
}