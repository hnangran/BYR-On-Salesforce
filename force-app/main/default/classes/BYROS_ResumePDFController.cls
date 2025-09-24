//Class to control the Visualforce page to display the resume as a printable PDF 
public with sharing class BYROS_ResumePDFController {
/*    
    //Expose variables to the VF page
    public BYROS_ResumeService.ResumeDetails resumeDetails { get; private set; }
    public String fileName { get; private set; }
    public String resumeId { get; private set; }
    public String errorMessage { get; private set; }

    public BYROS_ResumePDFController() {
        resumeId = ApexPages.currentPage().getParameters().get('selectedResumeId');

        //Get resume details
        resumeDetails = BYROS_ResumeService.getResumeDetails(resumeId);        

        //Set the file name
        String prof = String.isBlank(resumeDetails.profileName) ? 'Profile' : resumeDetails.profileName;
        String res  = String.isBlank(resumeDetails.resumeName)  ? 'Resume'  : resumeDetails.resumeName;
        fileName = prof + ' - ' + res + ' - ' + Date.today()  + '.pdf';

        //Set the content disposition to inline
        //ApexPages.currentPage().getHeaders().put('Content-Disposition', 'inline; filename=' + fileName);

        //Set the content type to PDF
        //ApexPages.currentPage().getHeaders().put('Content-Type', 'application/pdf');
        
    }
        */
}