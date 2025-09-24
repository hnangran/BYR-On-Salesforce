import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Resumestepbasicinfo extends LightningElement {

    @api resumeId; // ID of the Resume__c record

    //state variables
    isSubmitting = false;
    goNext = false;           // set when "Save & Continue" is clicked

    /** Convenience: get the record-edit-form */
    get resumeForm() {
        return this.template.querySelector('lightning-record-edit-form');
    }    

    /** Validate inputs before submit (lightning-input-field supports reportValidity) */
    validate() {
        const fields = this.template.querySelectorAll('lightning-input-field');
        let allValid = true;
        fields.forEach((f) => {
            const valid = f.reportValidity();
            if (!valid) allValid = false;
        });
        return allValid;
    }    

    handleResumeSubmit(event){

        //prevent accidental double submit and prevent submitting with invalid input
        if (this.isSubmitting || !this.validate()) {
            event.preventDefault();
            return;
        }
        this.isSubmitting = true;

    }

    handleResumeSuccess(event){
        const id = event?.detail?.id || this.resumeId;
        this.isSubmitting = false;

        // emit saved id (parent can store it)
        this.dispatchEvent(new CustomEvent('save', { detail: { resumeId: id } }));

        // toast
        this.toast('Success', this.resumeId ? 'Resume updated.' : 'Resume created.', 'success');

        // set local id after create
        if (!this.resumeId && event?.detail?.id) this.resumeId = event.detail.id;

        // advance only if Save & Continue
        if (this.goNext) {
            this.goNext = false;
            this.dispatchEvent(new CustomEvent('next', { detail: { resumeId: id } }));
        }        
    }

    handleResumeError(event){
        this.isSubmitting = false;
        const msg = event?.detail?.message || event?.detail?.detail || 'Save failed.';
        this.toast('Error', msg, 'error');        
    }

    //Called by Save and Continue from the parent
    handleSaveAndContinue(event){

        if (this.isSubmitting || !this.validate()) 
            return;

        this.goNext = true;
        this.isSubmitting = true;
        this.resumeForm.submit();        
    }


    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    @api
    save() {
        if (this.validate()) {
            this.resumeForm.submit();
        }
    }

    @api
    saveAndNext() {
        this.handleSaveAndContinue();
    }    

}