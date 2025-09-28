import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const STEPS = ['basic', 'education', 'work', 'skills', 'certs', 'review'];

export default class Createresume extends LightningElement {
    
    @api resumeId; // Store the resume ID
    @track stepIndex = 0;            // start at "basic"
    advanceAfterSubmit=false;

    isLoading=false;
    
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

    //Path click
    handleStepChange(e){
        const value = event?.detail?.value;
        const idx = STEPS.indexOf(value);
        if (idx !== -1) {
            this.stepIndex = idx;
        } else {
            console.warn('Unknown step value from path:', value);
        }    
}

    // Parent footer action - back
    handleBack() {
        if (!this.isFirstStep) this.stepIndex -= 1;
    }

    //parent footer action - next
    handleNext() {
        const child = this.getActiveChild();

        if (!child?.validate() ) 
            return;

        this.advanceAfterSubmit = true;
        child.submit();
    }

    handleFinish(){
        this.toast('Complete', 'Your resume has been saved.', 'success');
    }

    handleFormSubmit(e){
          console.log('Submitting fields:', JSON.parse(JSON.stringify(e.detail.fields)));
    }

    handleFormSuccess(e){
        const id = e?.detail?.id || this.resumeId;
        if (id && !this.resumeId) this.resumeId = id;

        this.toast('Success', 'Step saved successfully.', 'success');

        if (this.advanceAfterSubmit) {
            this.advanceAfterSubmit = false;
            if (!this.isLastStep) this.stepIndex += 1;
        }        
    }

    handleFormError(e){
        const d = e?.detail;
        const msg =
            d?.message ||
            d?.detail ||
            d?.output?.errors?.[0]?.message ||
            d?.output?.fieldErrors && Object.values(d.output.fieldErrors).flat().map(x => x.message).join('; ') ||
            'Submission failed. Check required fields / permissions / validation rules.';

        // eslint-disable-next-line no-console
        console.error('Record edit error detail:', JSON.parse(JSON.stringify(d)));
        this.toast('Error', msg, 'error');
        this._advanceAfterSubmit = false;
    }

    //parent footer action - save and next
    async handleSaveAndNext() {
        const child = this.getActiveChild();

        if (!child?.validate() ) 
            return;

        this.advanceAfterSave = true;
        child.submit();
    }

    getActiveChild() {
        switch (this.currentStep) {
            case 'basic':     return this.template.querySelector('c-basicinfostep');
            case 'education': return this.template.querySelector('c-educationstep');
            case 'work':      return this.template.querySelector('c-workexperiencestep');
            case 'skills':    return this.template.querySelector('c-skillsstep');
            case 'certs':     return this.template.querySelector('c-certsstep');
            case 'review':    return this.template.querySelector('c-reviewandfinishstep');
            default:          return null;
        }
    }

    toast(title, message, variant='info') {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}