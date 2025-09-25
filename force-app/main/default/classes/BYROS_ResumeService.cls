public with sharing class BYROS_ResumeService {
    public BYROS_ResumeService() {

    }

    // Class to hold profile data for combobox
    public class ProfileList {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    // Method to get all profiles
    @AuraEnabled(cacheable=true)
    public static List<ProfileList> getProfiles(){

        List<ProfileList> profiles = new List<ProfileList>();
        
        if (!Schema.sObjectType.Profile__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Profile records.');
        }
        
        System.debug('Entering ResumeService.getProfiles');

        for(Profile__c p : [SELECT Id, Name FROM Profile__c]){
            ProfileList profile = new ProfileList();
            profile.label = p.Name;
            profile.value = p.Id.toString();
            profiles.add(profile);
        }

        System.debug('Exiting ResumeService.getProfiles ' + profiles);

        return profiles;
    }

    // Class to hold resume data for combobox
    public class ResumeList {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    // Method to get resumes for a given profile
    @AuraEnabled(cacheable=true)
    public static List<ResumeList> getResumes(Id profileId){
        if (!Schema.sObjectType.Resume__c.isAccessible() || !Schema.sObjectType.Profile__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Resume or Profile records.');
        }

        if (profileId == null) return new List<ResumeList>();

        List<ResumeList> resumes = new List<ResumeList>();
        for(Resume__c r : [SELECT Id, Name, Profile__c, Profile__r.name FROM Resume__c WHERE Profile__c = :profileId]){
            ResumeList resume = new ResumeList();
            resume.label = r.Profile__r.name + ' - ' + r.Name;
            resume.value = r.Id.toString();
            resumes.add(resume);
        }
        return resumes;
    }

    @AuraEnabled (cacheable=true)
    public static List<ResumeList> getAllResumes(){
        if (!Schema.sObjectType.Resume__c.isAccessible() || !Schema.sObjectType.Profile__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Resume or Profile records.');
        }
        
        try {
            List<ResumeList> resumes = new List<ResumeList>();
            for(Resume__c r : [SELECT Id, Name, Profile__c, Profile__r.name  FROM Resume__c]){
                ResumeList resume = new ResumeList();
                resume.label = r.Profile__r.name + ' - ' + r.Name;
                resume.value = r.Id.toString();
                resumes.add(resume);
            }
            return resumes;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    // Class to hold detailed resume information
    public class ResumeDetails {

        //Profile__c fields
        @AuraEnabled public String profileId { get; set; }
        @AuraEnabled public String profileName { get; set; }
        @AuraEnabled public String applicantName { get; set; }
        @AuraEnabled public String applicantEmail { get; set; }
        @AuraEnabled public String applicantMobilePhone { get; set; }
        @AuraEnabled public String applicantCity { get; set; }
        @AuraEnabled public String applicantState { get; set; }

        //Resume__c fields
        @AuraEnabled public String resumeId { get; set; } 
        @AuraEnabled public String resumeName { get; set; } 
        @AuraEnabled public String summary { get; set; } 
        @AuraEnabled public String highlights { get; set; } 
        @AuraEnabled public String coverLetter { get; set; }

        //Related lists - Education, Experience, Skills, Certifications
        @AuraEnabled public List<EducationDetail> educationDetails { get; set; }
        @AuraEnabled public List<WorkExperienceDetail> workExperienceDetails { get; set; }
        @AuraEnabled public List<SkillDetail> skillDetails { get; set; }
        @AuraEnabled public List<CertificationDetail> certificationDetails { get; set; }

        public ResumeDetails() {
            educationDetails = new List<EducationDetail>();
            workExperienceDetails = new List<WorkExperienceDetail>();
            skillDetails = new List<SkillDetail>();
            certificationDetails = new List<CertificationDetail>();
        }
    }

    // Nested classes for resume-related details - Education, Experience, Skills, Certifications
    public class EducationDetail {
        @AuraEnabled public String id { get; set; } // ID of the Resume_Education__c junction object
        @AuraEnabled public String educationDetailId { get; set; } // ID of the Education__c record
        @AuraEnabled public String name { get; set; } // Name of the Education__c record
        @AuraEnabled public String institutionName { get; set; } // Institution Name from the Education__c record
        @AuraEnabled public String degreeType { get; set; } // Degree Type from the Education__c record
        @AuraEnabled public String fieldOfStudy { get; set; } // Major from the Education__c record
        @AuraEnabled public Date dateAchieved { get; set; } // Date Achieved from the Education__c record
    }

    public class WorkExperienceDetail {
        @AuraEnabled public String id { get; set; } // ID of the Resume_Experience__c junction object
        @AuraEnabled public String workExperienceDetailId { get; set; } // ID of the Work_Experience__c record
        @AuraEnabled public String name { get; set; } // Name of the Work_Experience__c record
        @AuraEnabled public String company { get; set; } // Company from the Work_Experience__c record
        @AuraEnabled public String role { get; set; } // Role from the Work_Experience__c record
        @AuraEnabled public String location { get; set; } // Location from the Work_Experience__c record
        @AuraEnabled public Date fromDate { get; set; } // From Date from the Work_Experience__c record
        @AuraEnabled public Date toDate { get; set; } // To Date from the Work_Experience__c record
        @AuraEnabled public String responsibilities { get; set; } // Responsibilities from the Resume_Experience__c junction object
    }

    public class SkillDetail {
        @AuraEnabled public String id { get; set; } // ID of the Resume_Skill__c junction object
        @AuraEnabled public String skillDetailId { get; set; } // ID of the Skill__c record
        @AuraEnabled public String skillName { get; set; }// Name of the Skill__c record
    }

    public class CertificationDetail {
        @AuraEnabled public String id { get; set; } // ID of the Resume_Certification__c junction object
        @AuraEnabled public String certificationDetailId { get; set; } // ID of the Certification__c record
        @AuraEnabled public String certificationName { get; set; } // Name of the Certification__c record
        @AuraEnabled public String issuer { get; set; } // Issuer from the Certification__c record
        @AuraEnabled public Date dateAchieved { get; set; }// Date Achieved from the Certification__c record
    }

    @AuraEnabled(cacheable=true)
    public static ResumeDetails getResumeDetails(Id resumeId){
        if (!Schema.sObjectType.Resume__c.isAccessible() || !Schema.sObjectType.Profile__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Resume or Profile records.');
        }

        ResumeDetails resumeDetails = new ResumeDetails();

        if (resumeId == null) return resumeDetails;

        // Query the resume and its related records
        Resume__c resume = [
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
            WHERE Id = :resumeId
        ];

        // Populate the ResumeDetails object

        // Populate Profile fields
        resumeDetails.profileId = resume.Profile__r.Id;
        resumeDetails.profileName = resume.Profile__r.Name;
        resumeDetails.applicantName = resume.profile__r.applicant_user__r.Name;
        resumeDetails.applicantEmail = resume.profile__r.applicant_user__r.email;
        resumeDetails.applicantMobilePhone = resume.profile__r.applicant_user__r.mobilephone;
        resumeDetails.applicantCity = resume.profile__r.applicant_user__r.city;
        resumeDetails.applicantState = resume.profile__r.applicant_user__r.state;

        //Populate Resume__c fields
        resumeDetails.resumeId = resume.Id;
        resumeDetails.resumeName = resume.Name;
        resumeDetails.summary = resume.Summary__c;
        resumeDetails.highlights = resume.Highlights__c;
        resumeDetails.coverLetter = resume.Cover_Letter__c;

        // Populate related details - Education
        List<EducationDetail> educationDetails = new List<EducationDetail>();
        for(Resume_Education__c e : resume.Linked_Education__r){
            EducationDetail eduDetail = new EducationDetail();
            eduDetail.id = e.Id; // ID of the junction object Resume_Education__c
            eduDetail.educationDetailId = e.Education__c; // ID of the Education__c detail record
            eduDetail.name = e.Education__r.Name; // Name of the Education__c detail record
            eduDetail.institutionName = e.Education__r.Institution_Name__c; // Institution Name from the Education__c record
            eduDetail.degreeType = e.Education__r.Degree_Type__c; // Degree Type from the Education__c record
            eduDetail.dateAchieved = e.Education__r.Date_Achieved__c; // Date Achieved from the Education__c record
            eduDetail.fieldOfStudy = e.Education__r.Field_of_Study__c; // Major from the Education__c record
            educationDetails.add(eduDetail);
        }
        resumeDetails.educationDetails = educationDetails;

        // Populate related details - Work Experience
        List<WorkExperienceDetail> workExperienceDetails = new List<WorkExperienceDetail>();
        for(Resume_Experience__c w : resume.Linked_Work_Experience__r){
            WorkExperienceDetail workExpDetail = new WorkExperienceDetail();
            workExpDetail.id = w.Id; // ID of the junction object Resume_Experience__c
            workExpDetail.workExperienceDetailId = w.Work_Experience__c; // ID of the Work_Experience__c detail record
            workExpDetail.name = w.Work_Experience__r.Name; // Name of the Work_Experience__c detail record
            workExpDetail.company = w.Work_Experience__r.Company__c; // Company from the Work_Experience__c record
            workExpDetail.role = w.Work_Experience__r.Role__c; // Role from the Work_Experience__c record
            workExpDetail.location = w.Work_Experience__r.Location__c; // Location from the Work_Experience__c record
            workExpDetail.fromDate = w.Work_Experience__r.From_Date__c; // From Date from the Work_Experience__c record
            workExpDetail.toDate = w.Work_Experience__r.To_Date__c; // To Date from the Work_Experience__c record
            workExpDetail.responsibilities = w.Responsibilities__c; // Responsibilities from the junction object Resume_Experience__c
            workExperienceDetails.add(workExpDetail);
        }
        resumeDetails.workExperienceDetails = workExperienceDetails;

        // Populate related details - Skills
        List<SkillDetail> skillDetails = new List<SkillDetail>();
        for(Resume_Skill__c s : resume.Linked_Skills__r){
            SkillDetail skillDetail = new SkillDetail();
            skillDetail.id = s.Id; // ID of the junction object Resume_Skill__c
            skillDetail.skillDetailId = s.Skill__c; // ID of the Skill__c detail record
            skillDetail.skillName = s.Skill__r.Name; // Name of the Skill__c detail record
            skillDetails.add(skillDetail);

        }
        resumeDetails.skillDetails = skillDetails;

        // Populate related details - Certifications
        List<CertificationDetail> certificationDetails = new List<CertificationDetail>();
        for(Resume_Certification__c c : resume.Linked_Certifications__r){
            CertificationDetail certDetail = new CertificationDetail();
            certDetail.id = c.Id; // ID of the junction object Resume_Certification__c
            certDetail.certificationDetailId = c.Certification__c; // ID of the Certification__c detail record
            certDetail.certificationName = c.Certification__r.Name; // Name of the Certification__c detail record
            certDetail.issuer = c.Certification__r.Issuer__c; // Issuer from the Certification__c record
            certDetail.dateAchieved = c.Certification__r.Date_Achieved__c; // Date Achieved from the Certification__c record
            certificationDetails.add(certDetail);
        }
        resumeDetails.certificationDetails = certificationDetails;

        return resumeDetails;
    }

}