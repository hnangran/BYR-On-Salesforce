import { LightningElement, api } from 'lwc';

export default class Basicinfostep extends LightningElement {

    @api resumeId; //parent passes id; if undefined -> create new resume

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
}