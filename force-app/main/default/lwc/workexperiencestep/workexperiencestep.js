import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUnlinkedResumeExperiences from '@salesforce/apex/BYROS_ResumeExperienceService.getUnlinkedResumeExperiences';
import getResumeExperiences from '@salesforce/apex/BYROS_ResumeExperienceService.getResumeExperiences';
import linkExperiences from '@salesforce/apex/BYROS_ResumeExperienceService.linkExperiences';
import unlinkExperiences from '@salesforce/apex/BYROS_ResumeExperienceService.unlinkExperiences';
import updateResumeExperienceResponsibilities from '@salesforce/apex/BYROS_ResumeExperienceService.updateResumeExperienceResponsibilities';
import updateWorkExperienceResponsibilities from '@salesforce/apex/BYROS_ResumeExperienceService.updateWorkExperienceResponsibilities';

export default class Workexperiencestep extends NavigationMixin(LightningElement) {
    @api resumeId;
    @track selectedExperiences = [];
    @track availableExperiences = [];
    @track showModal = false;
    @track showResponsibilitiesModal = false;
    @track editingId = null;
    @track editingResponsibilities = '';
    @track isEditingAvailable = false;

    selectedColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Company', fieldName: 'Company__c', type: 'text' },
        { label: 'Role', fieldName: 'Role__c', type: 'text' },
        { label: 'From Date', fieldName: 'From_Date__c', type: 'date' },
        { label: 'To Date', fieldName: 'To_Date__c', type: 'date' },
        { 
            type: 'button', 
            typeAttributes: { 
                label: 'Edit Responsibilities', 
                name: 'edit', 
                variant: 'neutral' 
            } 
        },
        { 
            type: 'button', 
            typeAttributes: { 
                label: 'Remove', 
                name: 'remove', 
                variant: 'destructive' 
            } 
        }
    ];

    availableColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Company', fieldName: 'Company__c', type: 'text' },
        { label: 'Role', fieldName: 'Role__c', type: 'text' },
        { label: 'From Date', fieldName: 'From_Date__c', type: 'date' },
        { label: 'To Date', fieldName: 'To_Date__c', type: 'date' },
        { 
            type: 'button', 
            typeAttributes: { 
                label: 'Edit Responsibilities', 
                name: 'edit', 
                variant: 'neutral' 
            } 
        },
        { 
            type: 'button', 
            typeAttributes: { 
                label: 'Add', 
                name: 'add', 
                variant: 'brand' 
            } 
        }
    ];

    connectedCallback() {
        if (this.resumeId) {
            this.loadExperienceData();
        }
    }

    async loadExperienceData() {
        if (!this.resumeId) return;
        
        try {
            const [selected, available] = await Promise.all([
                getResumeExperiences({ resumeId: this.resumeId }),
                getUnlinkedResumeExperiences({ resumeId: this.resumeId, limitSize: 50 })
            ]);
            this.selectedExperiences = selected || [];
            this.availableExperiences = available || [];
        } catch (error) {
            this.toast('Error', 'Failed to load work experience data: ' + this.getErrorMessage(error), 'error');
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'add') {
            this.handleAddExperience(row.Id);
        } else if (actionName === 'remove') {
            this.handleRemoveExperience(row.Id);
        } else if (actionName === 'edit') {
            const isAvailable = !row.ResumeExperienceId;
            const id = isAvailable ? row.Id : row.ResumeExperienceId;
            const responsibilities = isAvailable ? row.Responsibilities__c : row.Responsibilities;
            this.handleEditResponsibilities(id, responsibilities, isAvailable);
        }
    }

    handleEditResponsibilities(id, responsibilities, isAvailable = false) {
        this.editingId = id;
        this.isEditingAvailable = isAvailable;
        this.editingResponsibilities = responsibilities || '';
        this.showResponsibilitiesModal = true;
    }

    handleCloseResponsibilitiesModal() {
        this.showResponsibilitiesModal = false;
        this.editingId = null;
        this.isEditingAvailable = false;
        this.editingResponsibilities = '';
    }

    handleResponsibilitiesChange(event) {
        this.editingResponsibilities = event.target.value;
    }

    async handleSaveResponsibilities() {
        try {
            if (this.isEditingAvailable) {
                await updateWorkExperienceResponsibilities({ 
                    workExperienceId: this.editingId, 
                    responsibilities: this.editingResponsibilities 
                });
            } else {
                await updateResumeExperienceResponsibilities({ 
                    resumeExperienceId: this.editingId, 
                    responsibilities: this.editingResponsibilities 
                });
            }
            this.handleCloseResponsibilitiesModal();
            await this.loadExperienceData();
            this.toast('Success', 'Responsibilities updated', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to update responsibilities: ' + this.getErrorMessage(error), 'error');
        }
    }

    async handleAddExperience(experienceId) {
        try {
            await linkExperiences({ resumeId: this.resumeId, experienceIds: [experienceId] });
            await this.loadExperienceData();
            this.toast('Success', 'Work experience added to resume', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to add work experience: ' + this.getErrorMessage(error), 'error');
        }
    }

    async handleRemoveExperience(experienceId) {
        try {
            await unlinkExperiences({ resumeId: this.resumeId, experienceIds: [experienceId] });
            await this.loadExperienceData();
            this.toast('Success', 'Work experience removed from resume', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to remove work experience: ' + this.getErrorMessage(error), 'error');
        }
    }

    handleCreateNew() {
        this.showModal = true;
    }

    handleCloseModal() {
        this.showModal = false;
    }

    async handleExperienceCreated() {
        this.showModal = false;
        await this.loadExperienceData();
        this.toast('Success', 'Work experience record created', 'success');
    }

    @api validate() {
        return true;
    }

    @api submit() {
        const event = new CustomEvent('success', { detail: { id: this.resumeId } });
        this.dispatchEvent(event);
    }

    @api refresh() {
        this.loadExperienceData();
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    getErrorMessage(error) {
        return error?.body?.message || error?.message || 'Unknown error';
    }
}