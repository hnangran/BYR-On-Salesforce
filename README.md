# BYR-On-Salesforce
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
##

## Section 1 - Overview - About BYR-On-Salesforce
Build Your Resume (BYR) on Salesforce lets you manage your resumes and your various profiles in an organized and methodical way. But that's too simplistic, that is what we have documents for, so that one line there doesn't answer the question - "ok, but why do I need this?"

And honestly, you don't. This project/solution was meant to be a practice, get-your-hands-dirty kind of project that blew out of proportion once I got started. So here in this document I will attempt to explain what this is about, why it's helpful, who it's for, explain some of the architectural and technical considerations, and provide an idea or a brief list of the kind of roadmap features I might possibly some day build, some of which I think would be really cool.

Having started work on this project, I now envision the ideal future state of this solution as a living breathing AI-driven (yes, that is the buzz word these days), data and analytics-driven (there's another one) solution that truly unequivocally helps you get your next job. Not just that, in it's truly glamorous "I have arrived" form it will serve as your driver and your guide to push you towards where you want to go.

But for now, the goal of this project is to be educational and informative for anyone who new or established in the Salesforce development and architecture space. So having said all that, here's a quick overview:  
  
**1.1 Solution Name:** The name of this solution (as your might have guessed) is Build Your Resume (BYR) on Salesforce.  
   
**1.2 Description:** BYR is a Salesforce app built using LWC, Visualforce, Apex, and Salesforce low-code/no-code capabilities. The app allows an applicant (or author) to create and manage profiles, create, manage, and select resumes, preview them in HTML, and generate professional standardized PDF documents.  
  
**1.3 Goals, Objectives, and Value Statements:**  
1. Organization - Applicants can be better organized in creating and managing their resumes. As a result, they might find that they are able to apply to more jobs that fit their profile.  
2. Efficiency - By providing a standard format and an easy-to-use UI, applicants will be able to create resumes tailored to job descriptions with ease and efficiency.  
3. Standardized Professional Output: Reviewers will be able to view PDFs open in a standardized clean format, with consistent filenames and no Salesforce UI clutter.  
4. Responsiveness: Applicants will be able to view and edit resumes on a variety of platforms so that they can send resumes without delay.  

**1.4 Scope:**  
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

## Section 2 - High Level Architecture  



  
## Section 2 - User Personas, Actors, and Use Cases  
**User Personas:**  
This app was built with the the following user in mind:  
1. Anyone on the Salesforce platform who has access to Salesforce and is applying for jobs. This could be a user of Salesforce, an analyst, developer, project manager, director, executive, etc. It doesn't matter. If you have a dev org, you can install this solution and use it to manage the professional aspect of your life.  
  
But thinking some more about it, this app could also be used by the following users in the future:  
1. A resource manager in a professional services firm could use this solution to view resumes to staff their projects.  
2. A recruiter could use this solution with a view to better and more efficiently identify candidates that match their needs.  
3. A team or department manager could use this to get a systematic view of the various skillsets available to them to identify gaps, hiring, and training opportunities.  
  
For sake of simplicity, we will group these user personas into actors as below.  
  
**Actors:**  
**1. Applicant or Author** - this is the author (creator) and owner of the resume. Applicants want to create, update, view, delete, and print resumes. Additionally, Applicants could find value in managing and grouping their resumes by their capabilities or profiles.  
For example - An applicant who is a software developer may be proficient in full stack development and along the way they gained proficiency in Salesforce development. When they apply for jobs, they could apply for full stack development roles, or Salesforce development roles. Additionally, let's say they apply for 4-7 jobs on a weekly basis, and for each job application they modify and create a new version of their resume.  This solution will allow them to manage their different profiles ("Full Stack Developer", "Salesforce Developer"), easily create multiple versions of their resume, and group their resumes by profile.    


**2. Reviewer or Viewer** - this is the reviewer of the resume. They will be able to view applicant profiles and resumes. THey will not be able to modify the applicant's information.  

The first iteration of this solution is built for Applicants. Below are some use cases that the solution addresses from the Applicant's point of view.  

**Use Cases:**  
1. An Applicant is able to view, modify, and create profiles.  
2. An Applicant is able to view and create resumes.  
3. An Applicant is able to associate resumes with profiles.  
4. An Applicant is able to provide their contact information.  



## Section 3 - List of Features and Functional Requirements
1. Allow users to create resumes.
2. Allow users to create profiles and associate resumes with profiles.
3. Allow users to include the following information in their resumes - Summary, Highlights, Skills, Certifications, Work Experience, and Education.
4. Allow users to view and download resumes.


## Section 4 - Mapping the Use Cases, Features, and Functional Requirements

## Section 5 - Defining The Object Model (v1)

## Solution Design

## Section 5 - Future Enhancements
1. 

## Section 6 - Additional Sections

### A - An Explanation Of The LWC & HTML Display Components Used In The Solution  

**1. \<template\>**  
       - Defines the boundary.  
       - Everything inside <template> is what Salesforce will render when the component is placed on a Lightning page, App, or Record page.  
       - Supports conditional and looping directives (<template if:true={condition}>, <template for:each={list}>) to control what gets displayed.  
       - You can only have one root <template> per .html file. That’s the entry point. But nested templates are allowed inside it.  
          * The outer <template> is mandatory; the inner <template> tags need to be displayed conditionally and are used for conditional or iterative rendering. For example, <template if:true={displayResumeSelection}> displays the resume selection section of the page.  
      
**2. \<lightning-card\>**
- This is a container component provided by Salesforce to display content in a card layout, which consists of:  
  -- title  
  -- body  
  -- footer (optional)  
  -- icon (optional)
- It gives you a consistent Salesforce Lightning look-and-feel
- Great for grouping information in dashboards, forms, resume sections, record detail views, etc
- 

**3. <lightning-combobox>**
**4. <lightning-button>**
**5. <div>**



### An Explanation Of The Attributes Used For Styling


### Links and Resources
1. Salesforce Icons in Lightning - https://www.lightningdesignsystem.com/2e1ef8501/p/83309d-icons/b/586464
2. 

