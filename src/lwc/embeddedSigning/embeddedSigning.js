import { LightningElement, api, wire} from 'lwc';
import sendEnvelope from '@salesforce/apex/EmbeddedSigningController.sendEnvelope';
import getEmbeddedSigningUrl from '@salesforce/apex/EmbeddedSigningController.getEmbeddedSigningUrl';
import {getFieldValue, getRecord} from 'lightning/uiRecordApi';
import VCOC_STATUS_FIELD from '@salesforce/schema/User.Contact.VCoC_Status__c';


export default class EmbeddedSigning extends LightningElement {
 /*ID for development template
   template = 'e4113702-bf54-4877-859e-596ad4b039cb';
   */

   template = 'b57a2831-2aba-4062-81fe-458b88313cc2';
   description = 'Embedded Signing';

   @api signed = false;
   @api loaded = false;
   @api recordId;
   @api objectApiName;
   @api vcocstatus;
   contact;
   @wire(getRecord, {recordId: '$recordId', fields: [VCOC_STATUS_FIELD]})
   record({error,data}){
    if(error){
        this.error = 'Error';
    } else if (data){
        console.log('here is data', data);
        this.contact = data;
        this.vcocstatus = getFieldValue(this.contact, VCOC_STATUS_FIELD);
        console.log('here is status', this.vcocstatus);
        if(this.vcocstatus == 'Signed'){
            this.signed = true;
        }
    }
   }

   handleClick() {
    this.loaded = !this.loaded;
       sendEnvelope({template: this.template, description: this.description, recordId: this.recordId})
           .then((envelopeId) => (
               getEmbeddedSigningUrl({
                   envId: envelopeId,
                   url: window.location.href
               })
           ))
           .then((signingUrl) => {
               window.location.href = signingUrl;
           })
           .catch((error) => {
               console.log('Error:');
               console.log(error);
           });
   }
}