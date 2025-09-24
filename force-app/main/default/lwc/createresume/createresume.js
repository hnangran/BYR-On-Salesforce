import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const STEPS = ['basic', 'education', 'work', 'skills', 'certs', 'review'];

export default class Createresume extends LightningElement {
    
    //state variables
    @track isLoading=false;
    @track stepIndex = 0;            // start at "basic"
    //isEditMode=false;
    disableSave=true;
    disableSaveAndNext=true;
    disableFinalize=true;

    //variables to hold the state of each step
    //isFirstStep=true; //start on the basic info step, which is always the first step
    //isLastStep=false;

    //isStepBasic=true;
    //isStepEducation=false;
    //isStepWork=false;
    //isStepSkills=false;
    //isStepCerts=false;
    //isSteReview=false;
    hasStepError=false;

    //currentStep='basic';

    @api resumeId; // Store the resume ID
    resumeName;
    
    get isEditMode() { return !!this.resumeId; }
    get currentStep() { return STEPS[this.stepIndex]; }
    get isFirstStep() { return this.stepIndex === 0; }
    get isLastStep() { return this.stepIndex === STEPS.length - 1; }

    //step toggles
    get isStepBasic() { return this.currentStep === 'basic'; }
    get isStepEducation() { return this.currentStep === 'education'; }
    get isStepWork() { return this.currentStep === 'work'; }
    get isStepSkills() { return this.currentStep === 'skills'; }
    get isStepCerts() { return this.currentStep === 'certs';}
    get isStepReview()    { return this.currentStep === 'review'; }

    handleStepClick(evt){
        const value = evt?.detail?.value;
        if (!value) return;
        const idx = STEPS.indexOf(value);
        if (idx >= 0) this.stepIndex = idx;        
    }

    handleStepFocus(){}

    handleBack(event){
        if (!this.isFirstStep) this.stepIndex -= 1;
    }

    async handleSave(event){
        // Ask the active child to save (child should expose @api save())
        const child = this.getActiveChild();
        if (child?.save) {
            child.save(); // child will emit 'save' / 'stepvalidity' / toast on its own
        } else {
            this.toast('Action not available', 'This step does not support parent-controlled Save.', 'warning');
        }        
    }

    handleSaveAndNext(event){
        // Ask the active child to save & signal 'next' on success (child should expose @api saveAndNext())
        const child = this.getActiveChild();
        if (child?.saveAndNext) {
            child.saveAndNext();
        } else if (child?.save) {
            // Fallback: call save, and let child's onsuccess emit 'next'
            child.save();
        } else {
            this.toast('Action not available', 'This step does not support Save & Next.', 'warning');
        }        
    }

    handleFinalize(event){
        // Finalize action on Review step (e.g., ensure everything valid, then persist anything pending)
        if (!this.isStepReview) {
            this.toast('Not on Review', 'Go to Review to finalize.', 'warning');
            return;
        }
        try {
            this.isLoading = true;
            // TODO: call an Apex finalize method if needed
            this.toast('All set', 'Resume saved and finalized.', 'success');
        } catch (event) {
            this.toast('Finalize failed', this.err(event), 'error');
        } finally {
            this.isLoading = false;
        }                
    }
    
    handleCancel(event){
        // Simple: navigate back or fire an event so the container decides
        this.dispatchEvent(new CustomEvent('cancel'));        
    }

    handleChildSave(event){}

    handleFinalSave(event){}

    handleBackToEdit(event){}

    handleStepValidity(event){}

    handleChildError(event){
        this.toast('Error', event?.detail?.message || 'An error occurred', 'error');
    }

    handleSuccess(event){
        this.toast('Success', event?.detail?.message || 'Operation completed', 'success');
    }

    handleError(event){
        this.toast('Error', event?.detail?.message || 'An error occurred', 'error');
    }

    getActiveChild() {
        if (this.isStepBasic) {
            return this.template.querySelector('c-byros-resumestepbasicinfo');
        }
        // Add other steps as needed
        return null;
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    err(event) {
        try {
            if (!event) return '';
            if (typeof event === 'string') return event;
            if (event.detail && event.detail.message) return event.detail.message;
            return JSON.stringify(event);
        } catch {
            return 'Unexpected error';
        }
    }

}