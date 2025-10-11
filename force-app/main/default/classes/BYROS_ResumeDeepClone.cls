public with sharing class BYROS_ResumeDeepClone {
    
    public class Request {
        @InvocableVariable(required=true label='Resume ID')
        public Id resumeId;
    }

    public class Result {
        @InvocableVariable(label='New Resume ID')
        public Id newResumeId;
    }
    
    @InvocableMethod(label='Deep Clone Resume' description='Deep clone a Resume and all related records')
    public static List<Result> deepCloneResume(List<Request> requests) {
        if (requests == null || requests.isEmpty() || requests[0].resumeId == null) {
            return new List<Result>();
        }
        
        Id resumeId = requests[0].resumeId;

        Resume__c resume = [
            SELECT Id, Name, Summary__c, Highlights__c, Cover_Letter__c, Profile__c,
                (SELECT Id, Work_Experience__c, responsibilities__c FROM Linked_Work_Experience__r), 
                (SELECT Id, Certification__c FROM Linked_Certifications__r), 
                (SELECT Id, Education__c FROM Linked_Education__r), 
                (SELECT Id, Skill__c FROM Linked_Skills__r)
            FROM Resume__c 
            WHERE Id = :resumeId
            LIMIT 1
        ];

        Resume__c cloned = resume.clone(false, true, false, false);
        cloned.Name = resume.Name + ' (Copy)';
        insert cloned;
        
        List<Resume_Experience__c> clonedExperiences = new List<Resume_Experience__c>();
        List<Resume_Certification__c> clonedCertifications = new List<Resume_Certification__c>();
        List<Resume_Education__c> clonedEducation = new List<Resume_Education__c>();
        List<Resume_Skill__c> clonedSkills = new List<Resume_Skill__c>();
        
        for (Resume_Experience__c exp : resume.Linked_Work_Experience__r) {
            Resume_Experience__c clonedExp = exp.clone(false, true, false, false);
            clonedExp.Resume__c = cloned.Id;
            clonedExperiences.add(clonedExp);
        }
        
        for (Resume_Certification__c cert : resume.Linked_Certifications__r) {
            Resume_Certification__c clonedCert = cert.clone(false, true, false, false);
            clonedCert.Resume__c = cloned.Id;
            clonedCertifications.add(clonedCert);
        }
        
        for (Resume_Education__c edu : resume.Linked_Education__r) {
            Resume_Education__c clonedEdu = edu.clone(false, true, false, false);
            clonedEdu.Resume__c = cloned.Id;
            clonedEducation.add(clonedEdu);
        }
        
        for (Resume_Skill__c skill : resume.Linked_Skills__r) {
            Resume_Skill__c clonedSkill = skill.clone(false, true, false, false);
            clonedSkill.Resume__c = cloned.Id;
            clonedSkills.add(clonedSkill);
        }
        
        if (!clonedExperiences.isEmpty()) insert clonedExperiences;
        if (!clonedCertifications.isEmpty()) insert clonedCertifications;
        if (!clonedEducation.isEmpty()) insert clonedEducation;
        if (!clonedSkills.isEmpty()) insert clonedSkills;
        
        Result result = new Result();
        result.newResumeId = cloned.Id;
        return new List<Result>{ result };
    }
}
