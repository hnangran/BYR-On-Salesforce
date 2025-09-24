import { LightningElement, api } from 'lwc';
import getResumeDetails from '@salesforce/apex/BYROS_ResumeService.getResumeDetails'; // Import Apex method to get resume details

//this class displays resumedetails using the resumeId passed to it from the parent lwc viewresume
export default class DisplayResume extends LightningElement {

    _resumeId; // ID of the Resume__c record
    resumeDetails; // resume details
    error; // errors
    isLoading = false;
    resumeName;

    @api 
    set resumeId(value){
        this._resumeId = value;
        if(value){
            this.loadDetails();
        }
    }

    get resumeId(){
        return this._resumeId;
    }

    get hasResumeId() {
        return !!this._resumeId;
    }

    get getResumeName(){
        return this.resumeName;
    }

    async loadDetails(){
        this.isloading=true;
        try{
            const details = await getResumeDetails({resumeId: this._resumeId});
            this.resumeDetails = details;
            this.error = undefined;
        } catch(error){
            this.error = error?.body?.message || 'Error loading resume details';
            this.resumeDetails=undefined;
        }finally{
            this.isLoading=false;
        }
        
    }

    get SkillsString() {
        //return a string of skills separated by '|' 
        const skillDetails = this.resumeDetails.skillDetails;
        
        if(!skillDetails){
            return '';
        }

        if(skillDetails.length == 1){
            return this.resumeDetails.skillDetails[0].skillName;
        }

        let skillsString = '';
        for(let i = 0; i < skillDetails.length; i++){
            skillsString += skillDetails[i].skillName;  
            if(i < skillDetails.length - 1){
                skillsString += ' | ';
            }
        }
        return skillsString;
    }

    get CertificationsString() {
        
        //return a string of certifications separated by '|' 
        const certificationDetails = this.resumeDetails.certificationDetails;

        
        if(!certificationDetails){
            return '';
        }

        
        if(certificationDetails.length == 1){
            return this.resumeDetails.certificationDetails[0].certificationName;
        }
        

        let certificationsString = '';
        for(let i = 0; i < certificationDetails.length; i++){
            certificationsString += certificationDetails[i].certificationName;
            if(i < certificationDetails.length - 1){
                certificationsString += ' | ';
            }
        }
        return certificationsString;
    }

    /* This next method takes a resume ID passed into the lwc and loads the lwc with the resume details
    */
    @api
    loadResume(resumeId) {
        this._resumeId = resumeId;
        this.loadDetails();
    }

}