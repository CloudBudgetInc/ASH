import { LightningElement, api, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from 'lightning/navigation';
import addComment from "@salesforce/apex/CustomCommitteeMemberController.addComment";
import getCommitteeMembers from "@salesforce/apex/CustomCommitteeMemberController.getCommitteeMembers";
import customCommitteeMemberListStyle from "@salesforce/resourceUrl/customCommitteeMemberListStyle";
import getAssistant from "@salesforce/apex/CustomCommitteeMemberController.getAssistant";
import verifyHasEditPermissions from "@salesforce/apex/CustomCommitteeMemberController.verifyHasEditPermissions";
import { refreshApex } from '@salesforce/apex';

const columns = [
  {
    label: "Member",
    fieldName: "Contact_Name__c",
    hideDefaultActions: true,
    type: "button",
    typeAttributes: {
      label: { fieldName: "Contact_Name__c" },
      name: "show_details",
      title: "show_details",
      value: { fieldName: "Contact__c" },
      variant: "base"
    },
    wrapText: false
  },
  {
    label: "Position",
    fieldName: "Sub_Category__c",
    wrapText: false,
    hideDefaultActions: true
  },
  {
    label: "Start Date",
    fieldName: "Start__c",
    hideDefaultActions: true,
    type: "date",
    typeAttributes: {
      month: "numeric",
      day: "numeric",
      year: "numeric"
    },
    wrapText: false
  },
  {
    label: "End Date",
    fieldName: "End__c",
    hideDefaultActions: true,
    type: "date",
    typeAttributes: {
      month: "numeric",
      day: "numeric",
      year: "numeric"
    },
    wrapText: false
  }
];

export default class CustomCommitteeMemberList extends NavigationMixin(LightningElement) {
  @api recordId;
  @api emailBtnLabel;
  @api commentBtnLabel;
  @api emailTemplateId;
  @api emailSubject;
  // @track emailAddresses = '';
  @track members; // holds all member data from wire service (immutable);
  @track selectedList = "Current";
  @track loading = false;
  @track showDetail = false;
  @track showActions = false;
  @track empty = false;
  @track detail = "";
  @track selected = [];
  @track lists = [
    {
      id: "all",
      label: "All Committee Members",
      value: "All"
    },
    {
      id: "current",
      label: "Current Committee Members",
      value: "Current"
    },
    {
      id: "past",
      label: "Past Committee Members",
      value: "Past"
    },
    {
      id: "future",
      label: "Future Committee Members",
      value: "Future"
    }
  ];
  columns = columns;
  @track sortby = "select";
  @track thenby = "select";
  @track sortbyDesc = false;
  @track thenbyDesc = false;
  committeeMembers = [];
  currentMembers = [];
  pastMembers = [];
  futureMembers = [];
  wireResults;  // holds the entire { error, data } object from wire function. Used to refresh member data.

  // Member Detail variables.
  @track readOnly = true;
  @track hasExecutiveStaffPerms;
  @track success = false;
  @track error = false;

  @track isAssistant;
  

  constructor() {
    super();
    this.template.addEventListener("close", this.closeModal);
    this.template.addEventListener("cancel", this.closeEmailModal);
    this.template.addEventListener("toast", this.showToast);
  }

  connectedCallback() {
    loadStyle(this, customCommitteeMemberListStyle);
  }

  get listLabel() {
    return `${this.selectedList} Committee Members (${this.committeeMembersCount})`;
  }

  get sortOptions() {
    return [
      { label: "Select...", value: "select" },
      { label: "Member", value: "Contact_Name__c" },
      { label: "Position", value: "Sub_Category__c" },
      { label: "Start Date", value: "Start__c" },
      { label: "End Date", value: "End__c" }
    ];
  }

  get committeeMembersCount() {
    var count = this.currentMembers.length;
    if (this.selectedList === "All") {
      count = this.members.length;
    }
    if (this.selectedList === "Past") {
      count = this.pastMembers.length;
    }
    if (this.selectedList === "Future") {
      count = this.futureMembers.length;
    }
    this.empty = count === 0;
    return count;
  }

  getCurrentMembers() {
    if (this.members) {
      return this.members.filter(function (member) {
        const startDate = new Date(member.Start__c).getTime();
        const endDate = new Date(member.End__c).getTime();
        const today = new Date().getTime();

        // Allow members who have a startDate but no endDate to be considered current.
        if (member.End__c == null && startDate < today) {
          return true;
        }

        // Current Members are also:  startDate < today > endDate
        return endDate > today && startDate < today;
      });
    }
    return [];
  }

  getPastMembers() {
    if (this.members) {
      return this.members.filter(function (member) {
        const endDate = new Date(member.End__c).getTime();
        const today = new Date().getTime();
        return endDate < today;
      });
    }
    return [];
  }

  getFutureMembers() {
    if (this.members) {
      return this.members.filter(function (member) {
        const startDate = new Date(member.Start__c).getTime();
        const today = new Date().getTime();
        return startDate > today;
      });
    }
    return [];
  }

  @wire(verifyHasEditPermissions)
  permissionFetch({ error, data }) {
    if (data) {
      this.hasExecutiveStaffPerms = data;
    }
  }

  @wire(getCommitteeMembers, { id: "$recordId" })
  membersFetch(wireResults) {
    this.loading = true;

    this.wireResults = wireResults;
    const { data, error } = wireResults;

    if (data) {
      this.members = data;
      this.currentMembers = this.getCurrentMembers();
      this.pastMembers = this.getPastMembers();
      this.futureMembers = this.getFutureMembers();
      this.committeeMembers = this.getCurrentMembers(); // set to current as Current is default
      this.loading = false;
    } else if (error) {
      this.loading = false;
    }
  }

  handleSortDescChange(event) {
    this.sortbyDesc = event.detail.checked;
  }

  handleThenDescChange(event) {
    this.thenbyDesc = event.detail.checked;
  }

  handleSortByChange(event) {
    const sortbyValue = event.detail.value;
    this.sortby = sortbyValue;
  }

  handleThenByChange(event) {
    const thenbyValue = event.detail.value;
    this.thenby = thenbyValue;
  }

  handleRefresh() {
    this.updateSelectedList(); 

    if (this.sortby != "select") {
      if (this.thenby == this.sortby) {
        this.thenby = "select";
        this.thenbyDesc = false;
      }
      this.committeeMembers = this.handleSort(this.committeeMembers);
    }
    else {
      this.thenby = "select";
      this.thenbyDesc = false;
      this.sortbyDesc = false;
    }
  }

  updateSelectedList() {
    if (this.selectedList == "All") {
      this.committeeMembers = [...this.members];
    }
    if (this.selectedList == "Current") {
      this.committeeMembers = [...this.currentMembers];
    }
    if (this.selectedList == "Past") {
      this.committeeMembers = [...this.pastMembers];
    }
    if (this.selectedList == "Future") {
      this.committeeMembers = [...this.futureMembers];
    }
  }

  handleSort(memberList) {
    let localSort = this.sortby;
    let localThen = this.thenby;
    let localSortDesc = this.sortbyDesc;
    let localThenDesc = this.thenbyDesc;

    function sortThen(mem1, mem2, orderDesc, thenbyVal) {
      if (thenbyVal != "select") {
        if (orderDesc) {
          return mem1[thenbyVal] > mem2[thenbyVal] ? -1 : 1;
        }
        return mem1[thenbyVal] < mem2[thenbyVal] ? -1 : 1;
      }
      return 0;
    }

    memberList.sort(function (member1, member2) {
      // Member
      if (localSort == "Contact_Name__c") {
        if (member1.Contact_Name__c == member2.Contact_Name__c) {
          return sortThen(member1, member2, localThenDesc, localThen);
        }

        if (localSortDesc) {
          return member1.Contact_Name__c > member2.Contact_Name__c ? -1 : 1;
        }
        return member1.Contact_Name__c < member2.Contact_Name__c ? -1 : 1;
      }
      // Position
      if (localSort == "Sub_Category__c") {
        if (member1.Sub_Category__c == member2.Sub_Category__c) {
          return sortThen(member1, member2, localThenDesc, localThen);
        }
        
        if (localSortDesc) {
          return member1.Sub_Category__c > member2.Sub_Category__c ? -1 : 1;
        }
        return member1.Sub_Category__c < member2.Sub_Category__c ? -1 : 1;
      }
      // Start
      if (localSort == "Start__c") {
          const mem1Start = new Date(member1.Start__c).getTime();
          const mem2Start = new Date(member2.Start__c).getTime();

          if (mem1Start == mem2Start) {
            return sortThen(member1, member2, localThenDesc, localThen);
          }

          if (localSortDesc) {
            return mem1Start > mem2Start ? -1 : 1; 
          }
          return mem1Start < mem2Start ? -1 : 1;
      }
      // End
      if (localSort == "End__c") {
        const mem1End = new Date(member1.End__c).getTime();
        const mem2End = new Date(member2.End__c).getTime();

        if (mem1End == mem2End) {
          return sortThen(member1, member2, localThenDesc, localThen);
        }

        if (localSortDesc) {
          return mem1End > mem2End ? -1 : 1; 
        }
        return mem1End < mem2End ? -1 : 1;
      }
    });

    return memberList;
  }

  handleRowAction(event) {
    const action = event.detail.action;
    const row = event.detail.row;
    const rowData = JSON.parse(JSON.stringify(row));
    switch (action.name) {
      case "show_details":
        this.showDetail = true;
        this.detail = rowData;

        this.clearMemberDetailStatuses();


        getAssistant({ id: this.detail.Contact__r.Id })
          .then(res => {
            if (res != null) {
              this.isAssistant = res[0].Value__c;
            }
            else {
              this.isAssistant = '';
            }
          })
          .catch({})

        this.template.querySelector('[data-id="member-detail"]').scrollIntoView({block: "center"});
        break;
      default:
        this.showDetail = false;
        this.detail = "";
    }
  }

  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    this.selected = selectedRows;
    if (selectedRows.length > 0) {
      this.showActions = true;
    } else {
      this.showActions = false;
    }
  }

  handleMenuSelect(event) {
    const selectedItemValue = event.detail.value;
    this.selectedList = selectedItemValue;
  }

  handleRefreshData() {
    return refreshApex(this.wireResults); // refresh the member data.
  }

  handleViewMore() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.detail.Contact__c,
        objectApiName: 'Contact',
        actionName: 'view',
        target: '_blank',
      }
    });
  }

  // Clear the values of the vars responsible for the Member Detail comment section.
  clearMemberDetailStatuses() {
    this.readOnly = true;
    this.success = false;
    this.error = false;
  }
  
  handleClose() {
    this.showDetail = false;
    this.detail = "";

    this.clearMemberDetailStatuses();
  }

  handleEdit() {
    this.readOnly = false;
  }

  handleSubmit() {
    const textarea = this.template.querySelector('lightning-textarea');
    const comment = textarea.value;
    const previousComment = this.detail.Comments__c;

    if (previousComment !== comment) {
      this.loading = true;
      addComment({
        attributeId: this.detail.Id,
        comment: comment
      })
        .then(() => {
          this.success = true;
          this.error = undefined;
          this.loading = false;
          this.readOnly = true;

          this.handleRefreshData();
        })
        .catch(() => {
          this.loading = false;
          this.success = false;
          this.error = 'An error occurred. Please try again later.';
        });
    }
  }

  // getSelectedEmailAddresses() {
  //   const emailList = this.selected
  //     .filter(function (rowData) {
  //       return rowData.Contact__c && rowData.Contact__r.Email;
  //     })
  //     .map(function (rowData) {
  //       return rowData.Contact__r.Email;
  //     });

  //   const emails = emailList.join(', ');
  //   this.emailAddresses = emails;
  // }


  // handleOpenEmailDraft() {
  //   this.getSelectedEmailAddresses();

  //   const mailString = "mailto:" + this.emailAddresses;
  //   window.open(mailString, "_blank").focus();
  // }
}