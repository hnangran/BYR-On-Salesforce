//Class to control the Visualforce page to display the resume as a printable PDF 
public with sharing class BYROS_ResumePDFController {
    
    public BYROS_ResumeService.ResumeDetails resumeDetails { get; private set; }

    public Resume__c base { get; private set; }
    public String pdfTitle { get; private set; }                  // resume name -> card title
    public String applicantName { get; private set; }
    public String applicantEmail { get; private set; }
    public String applicantMobilePhone { get; private set; }
    public String applicantCity { get; private set; }
    public String applicantState { get; private set; }
    
    public String summary { get; private set; }
    public String highlightsHtml { get; private set; }            // rich text (escape=false)
    public String coverLetterHtml { get; private set; }           // rich text (escape=false)

    public String skillsString { get; private set; }              // “Skill A, Skill B…”
    public String certificationsString { get; private set; }      // “Cert A, Cert B…”

    public List<BYROS_ResumeService.WorkExperienceDetail> workExperienceDetails { get; private set; }
    public List<BYROS_ResumeService.EducationDetail> educationDetails { get; private set; }


    public BYROS_ResumePDFController(ApexPages.StandardController std){
        Id resumeId = std.getId();

        BYROS_ResumeService.ResumeDetails resumeDetails = BYROS_ResumeService.getResumeDetails(resumeId);

        pdfTitle             = resumeDetails.resumeName;
        applicantName        = resumeDetails.applicantName;
        applicantEmail       = resumeDetails.applicantEmail;
        applicantMobilePhone = resumeDetails.applicantMobilePhone;
        applicantCity        = resumeDetails.applicantCity;
        applicantState       = resumeDetails.applicantState;

        summary              = resumeDetails.summary;
        highlightsHtml       = resumeDetails.highlights;     // rich text HTML
        coverLetterHtml      = resumeDetails.coverLetter;    // rich text HTML

        // Build skills and certifications strings
        List<String> skillNames = new List<String>();
        for(BYROS_ResumeService.SkillDetail skill : resumeDetails.skillDetails) {
            skillNames.add(skill.skillName);
        }
        skillsString = String.join(skillNames, ', ');
        
        List<String> certNames = new List<String>();
        for(BYROS_ResumeService.CertificationDetail cert : resumeDetails.certificationDetails) {
            certNames.add(cert.certificationName);
        }
        certificationsString = String.join(certNames, ', ');

        workExperienceDetails = resumeDetails.workExperienceDetails;
        educationDetails = resumeDetails.educationDetails;

    }
}