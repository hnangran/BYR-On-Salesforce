# Build Your Resume (BYR) On Salesforce
## Documentation History
Update#: 1  
Date Modified: 08/31/2025  
Updates Made:  
  a. Uploaded the v1 ERF for the app object model  
  b. The Readme file explains the purpose of the app, the object model, and explores the initial set of use cases  

Update#: 2  
Date Modified: 09/01  
Updates Made:  
  a. Added Additional Sections

Update#: 2  
Date Modified: 09/02  
Updates Made:  
  a. Removed additional sections to keep this readme file lightweight. Going to move detailed information to the Wiki section.

##

## Overview - About BYR-On-Salesforce
Build Your Resume (BYR) on Salesforce lets you manage your resumes and your various profiles in an organized and methodical way. But that's too simplistic, that is what we have documents for, so that one line there doesn't answer the question - "ok, but why do I need this?"

And honestly, you don't. This project/solution was meant to be a practice, get-your-hands-dirty kind of project that blew out of proportion once I got started. So here in this document I will attempt to explain what this is about, why it's helpful, who it's for, explain some of the architectural and technical considerations, and provide an idea or a brief list of the kind of roadmap features I might possibly some day build, some of which I think would be really cool.

Having started work on this project, I now envision the ideal future state of this solution as a living breathing AI-driven (yes, that is the buzz word these days), data and analytics-driven (there's another one) solution that truly unequivocally helps you get your next job. Not just that, in it's truly glamorous "I have arrived" form it will serve as your driver and your guide to push you towards where you want to go.

But for now, the goal of this project is to be educational and informative for anyone who new or established in the Salesforce development and architecture space. So having said all that, here's a quick overview:  
  
### Solution Name  
The name of this solution (as your might have guessed) is Build Your Resume (BYR) on Salesforce.  
   
### Description  
BYR is a Salesforce app built using LWC, Visualforce, Apex, and Salesforce low-code/no-code capabilities. The app allows an applicant (or author) to create and manage profiles, create, manage, and select resumes, preview them in HTML, and generate professional standardized PDF documents.  
  
### Goals, Objectives, and Value Statements  
1. Organization - Applicants can be better organized in creating and managing their resumes. As a result, they might find that they are able to apply to more jobs that fit their profile.  
2. Efficiency - By providing a standard format and an easy-to-use UI, applicants will be able to create resumes tailored to job descriptions with ease and efficiency.  
3. Standardized Professional Output: Reviewers will be able to view PDFs open in a standardized clean format, with consistent filenames and no Salesforce UI clutter.  
4. Responsiveness: Applicants will be able to view and edit resumes on a variety of platforms so that they can send resumes without delay.  

### Scope  
**In scope for this first release:**  
1. Applicant flows for managing their resume profiles (create, view, update, delete), managing resumes (create, view, update, delete), selecting and viewing a resume within Salesforce, viewing a resume as a PDF for download, and downloading a PDF.  
2. Flows for selecting, viewing, and downloading resumes.  
3. Fixed formatting of the resume document.  
4. Fixed components of the resume document.  
  
**Out of scope for this first release:**  
1. Configurable resume components.  
2. Configurable resume document output.  
3. AI capabilities.  
4. Tracking job applications.  
5. Multi-language support.  
6. Integration with external portals.  
7. Analytics on resume usage.  
8. Other features not mentioned in this list and not mentioned in the in-scope list.  
  
### Salesforce components used in the development of this app  
1. Lightning Web Controls  
2. VisualForce  
3. Apex  
4. Salesforce custom objects and fields  
5. Salesforce low-code/no-code capabilities such as Flows  
