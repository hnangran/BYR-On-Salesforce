import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUnlinkedResumeSkills from '@salesforce/apex/BYROS_ResumeSkillService.getUnlinkedResumeSkills';
import getResumeSkills from '@salesforce/apex/BYROS_ResumeSkillService.getResumeSkills';
import linkSkills from '@salesforce/apex/BYROS_ResumeSkillService.linkSkills';
import unlinkSkills from '@salesforce/apex/BYROS_ResumeSkillService.unlinkSkills';

export default class Skillsstep extends NavigationMixin(LightningElement) {
    @api resumeId;
    @track selectedSkills = [];
    @track availableSkills = [];
    @track showModal = false;

    selectedColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
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
            this.loadSkillData();
        }
    }

    async loadSkillData() {
        if (!this.resumeId) return;
        
        try {
            const [selected, available] = await Promise.all([
                getResumeSkills({ resumeId: this.resumeId }),
                getUnlinkedResumeSkills({ resumeId: this.resumeId, limitSize: 50 })
            ]);
            this.selectedSkills = selected || [];
            this.availableSkills = available || [];
        } catch (error) {
            this.toast('Error', 'Failed to load skill data: ' + this.getErrorMessage(error), 'error');
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'add') {
            this.handleAddSkill(row.Id);
        } else if (actionName === 'remove') {
            this.handleRemoveSkill(row.Id);
        }
    }

    async handleAddSkill(skillId) {
        try {
            await linkSkills({ resumeId: this.resumeId, skillIds: [skillId] });
            await this.loadSkillData();
            this.toast('Success', 'Skill added to resume', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to add skill: ' + this.getErrorMessage(error), 'error');
        }
    }

    async handleRemoveSkill(skillId) {
        try {
            await unlinkSkills({ resumeId: this.resumeId, skillIds: [skillId] });
            await this.loadSkillData();
            this.toast('Success', 'Skill removed from resume', 'success');
        } catch (error) {
            this.toast('Error', 'Failed to remove skill: ' + this.getErrorMessage(error), 'error');
        }
    }

    handleCreateNew() {
        this.showModal = true;
    }

    handleCloseModal() {
        this.showModal = false;
    }

    async handleSkillCreated() {
        this.showModal = false;
        await this.loadSkillData();
        this.toast('Success', 'Skill record created', 'success');
    }

    @api validate() {
        return true;
    }

    @api submit() {
        const event = new CustomEvent('success', { detail: { id: this.resumeId } });
        this.dispatchEvent(event);
    }

    @api refresh() {
        this.loadSkillData();
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    getErrorMessage(error) {
        return error?.body?.message || error?.message || 'Unknown error';
    }
}
