import { LightningElement, api } from 'lwc';

export default class Basicinfostep extends LightningElement {

    @api resumeId; //parent passes id; if undefined -> create new resume
    // Placeholder text to demonstrate code changes
    @api placeholder = 'This is a placeholder text to demonstrate code changes.';

    @api validate(){
        return [...this.template.querySelectorAll('lightning-input-field')]
            .every(input => input.reportValidity());
    }

    // Parent-controlled save; returns the saved record Id
    @api async submit(){
        const form = this.template.querySelector('lightning-record-edit-form');
        if (form) 
            form.submit();
    }

    //set placeholder text when component is initialized
    connectedCallback() {
        this.placeholder = 'Resume ID: ' + (this.resumeId || 'New Resume');
    }
}