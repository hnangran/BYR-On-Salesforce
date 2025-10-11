import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUnlinkedResumeCertifications from '@salesforce/apex/BYROS_ResumeCertificationService.getUnlinkedResumeCertifications';
import getResumeCertifications from '@salesforce/apex/BYROS_ResumeCertificationService.getResumeCertifications';
import linkCertifications from '@salesforce/apex/BYROS_ResumeCertificationService.linkCertifications';
import unlinkCertifications from '@salesforce/apex/BYROS_ResumeCertificationService.unlinkCertifications';

export default class Certsstep extends NavigationMixin(LightningElement) {
    @api resumeId;
    @track selectedCertifications = [];
    @track availableCertifications = [];
    @track showModal = false;

    selectedColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Issuer', fieldName: 'Issuer__c', type: 'text' },
        { label: 'Date Achieved', fieldName: 'Date_Achieved__c', type: 'date' },
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
        { label: 'Issuer', fieldName: 'Issuer__c', type: 'text' },
        { label: 'Date Achieved', fieldName: 'Date_Achieved__c', type: 'date' },
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
            this.loadCertificationData();
        }
    }

    async loadCertificationData() {
        if (!this.resumeId) return;
        
        try {
            const [selected, available] = await Promise.all([
                getResumeCertifications({ resumeId: this.resumeId }),
                getUnlinkedResumeCertifications({ resumeId: this.resumeId, limitSize: 50 })
            ]);
            this.selectedCertifications = selected || [];
            this.availableCertifications = available || [];
        } catch (error) {
            this.toast('Error', 'Failed to load certification data: ' + this.getErrorMessage(error), 'error');
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'add') {
            this.handleAddCertification(row.Id);
        } else if (actionName === 'remove') {
            this.handleRemoveCertification(row.Id);
        }
    }

    async handleAddCertification(certificationId) {
        try {
            await linkCertifications({ resumeId: this.resumeId, certificationIds: [certificationId] });
            await this.loadCertificationData();
            this.toast('Success', 'Certification added to resume', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to add certification: ' + this.getErrorMessage(error), 'error');
        }
    }

    async handleRemoveCertification(certificationId) {
        try {
            await unlinkCertifications({ resumeId: this.resumeId, certificationIds: [certificationId] });
            await this.loadCertificationData();
            this.toast('Success', 'Certification removed from resume', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to remove certification: ' + this.getErrorMessage(error), 'error');
        }
    }

    handleCreateNew() {
        this.showModal = true;
    }

    handleCloseModal() {
        this.showModal = false;
    }

    async handleCertificationCreated() {
        this.showModal = false;
        await this.loadCertificationData();
        this.toast('Success', 'Certification record created', 'success');
    }

    @api validate() {
        return true;
    }

    @api submit() {
        const event = new CustomEvent('success', { detail: { id: this.resumeId } });
        this.dispatchEvent(event);
    }

    @api refresh() {
        this.loadCertificationData();
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    getErrorMessage(error) {
        return error?.body?.message || error?.message || 'Unknown error';
    }
}