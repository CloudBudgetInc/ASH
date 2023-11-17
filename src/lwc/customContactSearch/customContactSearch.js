import { LightningElement, api, track  } from 'lwc';
import searchContacts from "@salesforce/apex/CustomContactSearchController.searchContacts";

export default class CustomContactSearch extends LightningElement {
  searchTerm;
  applyFilter = false;
  @api baseUrl;
  @track results;
  @track showResults = false;
  @track loading = false;
  @track error = undefined;
  
  handleSearch() {
    this.loading = true;
    searchContacts({ searchTerm: this.searchTerm, applyFilter: this.applyFilter })
      .then((res) => {
        if (res) {
          if (res.length > 0) {
            const that = this;
            this.results = res.map(function(attr) {
              return {
                ...attr,
                url: `${that.baseUrl}/lightning/r/Contact/${attr.Id}/view`
              }
            });

            this.showResults = true;
          }
        } else {
          this.results = null;
        }
        this.error = undefined;
        this.loading = false;
      })
      .catch((error) => {
        this.loading = false;
        this.error = 'An error occurred while searching. Please modify your search or try again later.';
        this.showResults = false;
      });
  }
    
  handleKeyUp(e) {
    const isEnterKey = e.keyCode === 13;
    if (isEnterKey) {
      this.searchTerm = e.target.value;
      if (e.target.value.length) {
        this.handleSearch();
      } else {
        this.showResults = false;
      }
    }
  }
  
  handleChecked(e) {
    this.applyFilter = e.target.checked;
  }
}