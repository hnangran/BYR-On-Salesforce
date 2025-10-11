public with sharing class ResumeDeepClone {
    public ResumeDeepClone() {}

    public class Request {
        @InvocableVariable(required=true label='Resume IDs')
        public List<Id> resumeIds;
    }

    public class Result {
        @InvocableVariable(label='Old Resume ID')
        public Id oldResumeId;
        
        @InvocableVariable(label='New Resume ID')
        public Id newResumeId;
        
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }
    
    @InvocableMethod(label='Deep Clone Resumes' description='Deep clone Resumes and all related records')
    public static List<Result> deepCloneResumes(List<Request> requests) {
        // Gather all IDs across requests (supports both single and bulk)
        Set<Id> resumeIds = new Set<Id>();
        for (Request req : requests) {
            if (req.resumeIds != null) {
                resumeIds.addAll(req.resumeIds);
            }
        }
        if (resumeIds.isEmpty()) {
            return new List<Result>();
        }

        // Query the resume and its related records
        List<Resume__c> resumes = [
            //Get top level resume fields from the Resume__c object
            SELECT Id, Name, Summary__c, Highlights__c, Cover_Letter__c,

                //Get related profile fields from the Profile__c object
                Profile__c, Profile__r.id, Profile__r.name,

                //Get fields from the User object related to the Profile object
                profile__r.applicant_user__c, profile__r.applicant_user__r.name, 
                profile__r.applicant_user__r.email, profile__r.applicant_user__r.mobilephone, 
                profile__r.applicant_user__r.city, profile__r.applicant_user__r.state,

                //Get related records from the junction object for Work Experience
                //Relationship =Linked_Work_Experience__r
                //Object = Resume_Experience__c
                (SELECT ID, Name, Resume__c, Work_Experience__c, responsibilities__c, 
                        Work_Experience__r.id, Work_Experience__r.name, Work_Experience__r.company__c, 
                        Work_Experience__r.role__c, Work_Experience__r.location__c,
                        Work_Experience__r.from_date__c, Work_Experience__r.to_date__c 
                FROM Linked_Work_Experience__r), 

                //Get related records from the junction object for Certiifications
                //Relationship = Linked_Certifications__r
                //Object = Resume_Certification__c
                (SELECT ID, Name, Resume__c, Certification__c, Certification__r.id, Certification__r.name, 
                        Certification__r.issuer__c, Certification__r.date_achieved__c 
                FROM Linked_Certifications__r), 

                //Get related records from the junction object for Education
                //Relationship = Linked_Education__r
                //Object = Resume_Education__c
                (SELECT ID, Name, Resume__c, Education__c, Education__r.id, Education__r.name, 
                        Education__r.institution_name__c, Education__r.degree_type__c, 
                        Education__r.field_of_study__c, Education__r.date_achieved__c 
                FROM Linked_Education__r), 

                //Get related records from the junction object for Skills
                //Relationship = Linked_Skills__r
                //Object = Resume_Skill__c
                (SELECT ID, Name, Resume__c, Skill__c, Skill__r.id, Skill__r.name 
                FROM Linked_Skills__r)

            //back to the top level object Resume__c
            FROM Resume__c 
            WHERE Id IN :resumeIds
        ];
        
        if (resumes.isEmpty()) {
            return new List<Result>();
        }

        // Clone resumes and related records
        List<Resume__c> clonedResumes = new List<Resume__c>();
        Map<Id, Resume__c> oldToNewResumeMap = new Map<Id, Resume__c>();
        
        for (Resume__c resume : resumes) {
            Resume__c cloned = resume.clone(false, true, false, false);
            cloned.Name = resume.Name + ' (Copy)';
            clonedResumes.add(cloned);
            oldToNewResumeMap.put(resume.Id, cloned);
        }
        
        insert clonedResumes;
        
        // Clone junction records
        List<Resume_Experience__c> clonedExperiences = new List<Resume_Experience__c>();
        List<Resume_Certification__c> clonedCertifications = new List<Resume_Certification__c>();
        List<Resume_Education__c> clonedEducation = new List<Resume_Education__c>();
        List<Resume_Skill__c> clonedSkills = new List<Resume_Skill__c>();
        
        for (Resume__c resume : resumes) {
            Resume__c newResume = oldToNewResumeMap.get(resume.Id);
            
            for (Resume_Experience__c exp : resume.Linked_Work_Experience__r) {
                Resume_Experience__c clonedExp = exp.clone(false, true, false, false);
                clonedExp.Resume__c = newResume.Id;
                clonedExperiences.add(clonedExp);
            }
            
            for (Resume_Certification__c cert : resume.Linked_Certifications__r) {
                Resume_Certification__c clonedCert = cert.clone(false, true, false, false);
                clonedCert.Resume__c = newResume.Id;
                clonedCertifications.add(clonedCert);
            }
            
            for (Resume_Education__c edu : resume.Linked_Education__r) {
                Resume_Education__c clonedEdu = edu.clone(false, true, false, false);
                clonedEdu.Resume__c = newResume.Id;
                clonedEducation.add(clonedEdu);
            }
            
            for (Resume_Skill__c skill : resume.Linked_Skills__r) {
                Resume_Skill__c clonedSkill = skill.clone(false, true, false, false);
                clonedSkill.Resume__c = newResume.Id;
                clonedSkills.add(clonedSkill);
            }
        }
        
        if (!clonedExperiences.isEmpty()) insert clonedExperiences;
        if (!clonedCertifications.isEmpty()) insert clonedCertifications;
        if (!clonedEducation.isEmpty()) insert clonedEducation;
        if (!clonedSkills.isEmpty()) insert clonedSkills;
        
        // Build results
        List<Result> results = new List<Result>();
        for (Id oldId : oldToNewResumeMap.keySet()) {
            Result r = new Result();
            r.oldResumeId = oldId;
            r.newResumeId = oldToNewResumeMap.get(oldId).Id;
            results.add(r);
        }
        
        return results;
    }
}