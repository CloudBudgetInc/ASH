import { LightningElement, api, track, wire } from 'lwc';
import getUserByContactId from '@salesforce/apex/CustomUserProfilePhotoController.getUserByContactId';
import getContact from '@salesforce/apex/CustomUserProfilePhotoController.getContact';
import isCurrentUser from '@salesforce/apex/CustomUserProfilePhotoController.isCurrentUser';
import getProfileImage from '@salesforce/apex/CustomUserProfilePhotoController.getProfileImage';
import uploadProfileImage from '@salesforce/apex/CustomUserProfilePhotoController.uploadProfileImage';
import deleteProfileImage from '@salesforce/apex/CustomUserProfilePhotoController.deleteProfileImage';

export default class CustomProfilePhoto extends LightningElement {
  @api recordId;
  @track user;
  @track contact;
  @track isCurrentUser;
  @track profileImage;
  @track dropdownClass = 'sf-profile__dropdown slds-dropdown-trigger slds-dropdown-trigger_click';
    
  addCSS() {
   this.dropdownClass = 'sf-profile__dropdown slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
  }
  
  removeCSS() {
   this.dropdownClass = 'sf-profile__dropdown slds-dropdown-trigger slds-dropdown-trigger_click';
  }

  fetchIsCurrentUser(userId) {
    isCurrentUser({userId})
    .then(res => {
      this.isCurrentUser = res;
    })
    .catch(error => {
      console.log('error', error);
    });
  }

  fetchProfileImage(userId) {
    getProfileImage({userId})
    .then(res => {
      this.profileImage = res;
    })
    .catch(error => {
      console.log('error', error);
    });
  }

  uploadNewImage(file, base64Data) {
    uploadProfileImage({
      base64Data, 
      contentType: file.type,
      fileName: file.name
    }).then(res => {
      if (res) {
        window.location.reload();
      }
    })
    .catch(error => {
      console.log('error', error);
    });
  }

  delProfileImage() {
    deleteProfileImage()
    .then(res => {
      window.location.reload();
    })
    .catch(error => {
      console.log('error', error);
    });
  }

  @wire(getUserByContactId, {contactId: '$recordId'})
    userFetch({ error, data }) {
    if (data) {
      this.user = data;
      this.fetchIsCurrentUser(data.Id);
      this.fetchProfileImage(data.Id);
    } else if (error) {
      this.error = error;
      console.log('error', error);
    }
  }

  @wire(getContact, {contactId: '$recordId'})
    contactFetch({ error, data }) {
    if (data) {
      this.contact = data;
    } else if (error) {
      this.error = error;
      console.log('error', error);
    }
  }

  get hasProfileImage() {
    return this.profileImage && this.profileImage.largePhotoUrl;
  }

  get photoUrl() {
    return this.profileImage.largePhotoUrl;
  }

  handleImageUpload(event) {
    const that = this;
    if (event.target.files && event.target.files.length > 0) {
      const file = event.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onloadend = function() {
        const dataURL = reader.result;
        const base64Data = dataURL.match(/,(.*)$/)[1];
        that.uploadNewImage(file, base64Data);
      };
      reader.readAsDataURL(file);
    }
	}

  handeleDelete() {
    const that = this;
    that.delProfileImage();
  }

  handleToggleMenu(ev) {
    const that = this;
    const dropdown = that.template.querySelector('[data-id="dropdown-container"]');
    if (dropdown) {
      const className = this.template.querySelector('[data-id="dropdown-container"]').className;
      if (className === 'sf-profile__dropdown slds-dropdown-trigger slds-dropdown-trigger_click') {
        that.addCSS();
      } else {
        that.removeCSS();
      }
    }
  }
}