import { LightningElement, wire } from 'lwc';
import getProfiles from '@salesforce/apex/BYROS_ResumeService.getProfiles'; // Import Apex method to get profiles
import getResumes from '@salesforce/apex/BYROS_ResumeService.getResumes';


export default class Selectresume extends LightningElement {

    //load variables

    loadDisabled=true;
    downloadDisabled=true;

    //Profiles
    profiles=[];
    profilePlaceholder='Select a profile';
    selectedProfileId=undefined;
    profileError=undefined;

    //Resumes
    resumes=[];
    resumePlaceholder='Select a profile first...';
    selectedResumeId;
    resumeError;

    @wire(getProfiles)
    wiredProfiles({data, error}) {
        if (data)
            this.profiles = data;
        else if (error)
            this.profileError = error;
    }
    
    handleProfileChange(event){

        this.selectedProfileId = event.detail.value;

        //Reset resume selection
        this.selectedResumeId = undefined;
        this.resumePlaceholder = 'Loading resumes...';
        this.resumeError = undefined;
        this.resumes = [];

        //Reset load variables
        this.loadDisabled=true;
        this.downloadDisabled=true;

        //Load resumes when profile is selected
        getResumes({profileId: this.selectedProfileId}) 
        .then(result => {
            this.resumes = result;            
            this.resumePlaceholder = "Resumes found: " + result.length;
        }) 
        .catch(error => {
            this.resumeError = error;
            this.resumePlaceholder = "No resumes found";
        });

        const profileId = this.selectedProfileId;
        this.dispatchEvent(new CustomEvent('profilechange', {
            detail: { profileId }, bubbles: true, composed: true
        }));

        // Also clear the current resume selection upstream
        this.dispatchEvent(new CustomEvent('resumechange', {
            detail: { resumeId: null }, bubbles: true, composed: true
        }));

    }

    handleResumeChange(event){
        this.selectedResumeId = event?.detail?.value;
        
        //Enable buttons now that a resume is selected
        this.loadDisabled=false;
        this.downloadDisabled=false;

        const resumeId = this.selectedResumeId;
        this.dispatchEvent(new CustomEvent('resumechange', {
            detail: { resumeId }, bubbles: true, composed: true
        }));

    }

    loadResume(){
        //send resumeID to the parent component viewresume so that viewresume can pass it on to displayresume
        //displayresume will then show the resume details 
        
        const resumeId = this.selectedResumeId;
        try{
            this.dispatchEvent(
                new CustomEvent('displayresume', {
                    detail: {resumeId},
                    bubbles: true,
                    composed: true
                })
            );
        } catch (error){
            console.error('Error sending resumeID to parent component: ' + error);
        }
    }

    downloadPdf() {
        const url = '/apex/BYROS_ResumeAsPDF?id=' + this.selectedResumeId;
        window.open(url, '_blank'); // opens PDF in new tab
    }
}