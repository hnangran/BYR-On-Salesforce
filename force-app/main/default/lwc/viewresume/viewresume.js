import { LightningElement } from 'lwc';

export default class Viewresume extends LightningElement {
    displayResumeSelection=true;
    displayResumeDetails=false;
    selectedResumeId;

    handleProfileChange(event) {
        //Reset resume selection
        this.selectedResumeId = undefined;
        this.displayResumeDetails = false;
    }

    //get the resumeid passed by selectresume and make it available to displayresume
    handleDisplayResume(event) {
        this.displayResumeDetails = true;
    }

    handleResumeChange(event) {
        this.selectedResumeId = event?.detail?.resumeId;
        this.displayResumeDetails = false;
    }

    get showDetails(){
        return this.displayResumeDetails;
    }

}