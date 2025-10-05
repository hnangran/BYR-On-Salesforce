import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUnlinkedResumeEducations from '@salesforce/apex/BYROS_ResumeEducationService.getUnlinkedResumeEducations';
import getResumeEducations from '@salesforce/apex/BYROS_ResumeEducationService.getResumeEducations';
import linkEducations from '@salesforce/apex/BYROS_ResumeEducationService.linkEducations';
import unlinkEducations from '@salesforce/apex/BYROS_ResumeEducationService.unlinkEducations';

export default class Educationstep extends NavigationMixin(LightningElement) {
    @api resumeId;
    @track selectedEducations = [];
    @track availableEducations = [];

    selectedColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Institution', fieldName: 'Institution_Name__c', type: 'text' },
        { label: 'Degree', fieldName: 'Degree_Type__c', type: 'text' },
        { label: 'Field of Study', fieldName: 'Field_of_Study__c', type: 'text' },
        { label: 'Date', fieldName: 'Date_Achieved__c', type: 'date' },
        { type: 'action', typeAttributes: { rowActions: this.getRemoveActions } }
    ];

    availableColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Institution', fieldName: 'Institution_Name__c', type: 'text' },
        { label: 'Degree', fieldName: 'Degree_Type__c', type: 'text' },
        { label: 'Field of Study', fieldName: 'Field_of_Study__c', type: 'text' },
        { label: 'Date', fieldName: 'Date_Achieved__c', type: 'date' },
        { type: 'action', typeAttributes: { rowActions: this.getAddActions } }
    ];

    connectedCallback() {
        if (this.resumeId) {
            this.loadEducationData();
        }
    }

    async loadEducationData() {
        try {
            const [selected, available] = await Promise.all([
                getResumeEducations({ resumeId: this.resumeId }),
                getUnlinkedResumeEducations({ resumeId: this.resumeId, limitSize: 50 })
            ]);
            this.selectedEducations = selected || [];
            this.availableEducations = available || [];
        } catch (error) {
            this.toast('Error', 'Failed to load education data: ' + this.getErrorMessage(error), 'error');
        }
    }

    getAddActions() {
        return [{ label: 'Add to Resume', name: 'add' }];
    }

    getRemoveActions() {
        return [{ label: 'Remove', name: 'remove' }];
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'add') {
            this.handleAddEducation(row.Id);
        } else if (actionName === 'remove') {
            this.handleRemoveEducation(row.Id);
        }
    }

    async handleAddEducation(educationId) {
        try {
            await linkEducations({ resumeId: this.resumeId, educationIds: [educationId] });
            await this.loadEducationData();
            this.toast('Success', 'Education added to resume', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to add education: ' + this.getErrorMessage(error), 'error');
        }
    }

    async handleRemoveEducation(educationId) {
        try {
            await unlinkEducations({ resumeId: this.resumeId, educationIds: [educationId] });
            await this.loadEducationData();
            this.toast('Success', 'Education removed from resume', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to remove education: ' + this.getErrorMessage(error), 'error');
        }
    }

    handleCreateNew() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Education__c',
                actionName: 'new'
            }
        });
    }

    @api validate() {
        return true;
    }

    @api submit() {
        const event = new CustomEvent('success', { detail: { id: this.resumeId } });
        this.dispatchEvent(event);
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    getErrorMessage(error) {
        return error?.body?.message || error?.message || 'Unknown error';
    }
}
