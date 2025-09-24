/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BYROS_ResumeServiceTest {

    @TestSetup
    static void createTestData(){

        // Create test data
        System.debug('Entering ResumeServiceTest.createTestData, inserting profiles');

        //Insert Profiles
        insert new Profile__c(Name='Profile A');
        insert new Profile__c(Name='Profile B');

        // Retrieve profiles
        List<Profile__c> profiles = [SELECT Id, Name FROM Profile__c];

        System.debug('Inside ResumeServiceTest.createTestData, inserted profiles ' + profiles);

        System.debug('Inside ResumeServiceTest.createTestData, inserting resumes');
        
        // Insert resumes for profiles
        insert new Resume__c(Name='Resume A1', profile__c = profiles[0].Id);
        insert new Resume__c(Name='Resume A2', profile__c = profiles[0].Id);
        insert new Resume__c(Name='Resume B1', profile__c = profiles[1].Id);
        
        List<Resume__c> resumes = [SELECT Id, Name, profile__c FROM Resume__c];

        //insert Education, Work Experience, Skills, and Certifications
        //insert junction objects
        //update resume and junction relationships
        System.debug('Inside ResumeServiceTest.createTestData, inserting education, work experience, skills, and certifications');

        insert new Education__c(Name='Education A1', Institution_Name__c='Institution A1', Degree_Type__c='Degree Type A1', Field_of_Study__c='Field of Study A1', Date_Achieved__c=Date.today());
        insert new Education__c(Name='Education A2', Institution_Name__c='Institution A2', Degree_Type__c='Degree Type A2', Field_of_Study__c='Field of Study A2', Date_Achieved__c=Date.today());
        List<Education__c> educationRecords = [SELECT Id, Name, Institution_Name__c, Degree_Type__c, Field_of_Study__c, Date_Achieved__c FROM Education__c];
        System.debug('Inside ResumeServiceTest.createTestData, inserted education records ' + educationRecords);

        insert new Work_Experience__c(Name='Work Experience A1', Company__c='Company A1', Role__c='Role A1', Location__c='Location A1', From_Date__c=Date.today(), To_Date__c=Date.today());
        List<Work_Experience__c> workExperienceRecords = [SELECT Id, Name, Company__c, Role__c, Location__c, From_Date__c, To_Date__c FROM Work_Experience__c];
        System.debug('Inside ResumeServiceTest.createTestData, inserted work experience records ' + workExperienceRecords);

        insert new Skill__c(Name='Skill A1');
        List<Skill__c> skillRecords = [SELECT Id, Name FROM Skill__c];
        System.debug('Inside ResumeServiceTest.createTestData, inserted skill records ' + skillRecords);

        insert new Certification__c(Name='Certification A1');
        List<Certification__c> certificationRecords = [SELECT Id, Name FROM Certification__c];
        System.debug('Inside ResumeServiceTest.createTestData, inserted certification records ' + certificationRecords);

        insert new Resume_Skill__c(Resume__c = resumes[0].Id, Skill__c = skillRecords[0].Id);
        insert new Resume_Experience__c(Resume__c = resumes[0].Id, Work_Experience__c = workExperienceRecords[0].Id);
        insert new Resume_Certification__c(Resume__c = resumes[0].Id, Certification__c = certificationRecords[0].Id);
        insert new Resume_Education__c(Resume__c = resumes[0].Id, Education__c = educationRecords[0].Id);
        System.debug('Inside ResumeServiceTest.createTestData, inserted junction objects');

        System.debug('Exiting ResumeServiceTest.createTestData ' );

    }

    @IsTest 
    static void testGetProfiles() {
        //Test coverage for getProfiles
        Test.startTest();
        List<ResumeService.ProfileList> profileList = ResumeService.getProfiles();
        System.debug('Inside ResumeServiceTest.testGetProfiles, Testing coverage for getProfiles ' + profileList);
        Test.stopTest();

        System.assertEquals(2, profileList.size(), 'Expected 2 profiles');
    }

    @IsTest 
    static void testGetResumesForProfile() {
        //Test coverage for getResumes(profileId)
        Test.startTest();
        List<BYROS_ResumeService.ProfileList> profileList = BYROS_ResumeService.getProfiles();
        List<BYROS_ResumeService.ResumeList> resumeList = BYROS_ResumeService.getResumes(profileList[0].value);
        System.debug('Inside ResumeServiceTest.testGetResumesForProfile, Testing coverage for getResumes(profileId) ' + resumeList);
        Test.stopTest();

        System.assertEquals(2, resumeList.size(), 'Expected 2 resumes');
    }

    @IsTest 
    static void testGetAllResumes() {
        //Test coverage for getAllResumes()
        Test.startTest();
        List<BYROS_ResumeService.ResumeList> allResumes = BYROS_ResumeService.getAllResumes();
        System.debug('Inside ResumeServiceTest.testGetAllResumes, Testing coverage for getAllResumes() ' + allResumes);
        Test.stopTest();

        System.assertEquals(3, allResumes.size(), 'Expected 3 resumes');     
    }

    @IsTest 
    static void testGetResumeDetails() {    
        //Test coverage for getResumeDetails(resumeId)
        Test.startTest();
        List<BYROS_ResumeService.ResumeList> allResumes = BYROS_ResumeService.getAllResumes();
        BYROS_ResumeService.ResumeDetails resumeDetails = BYROS_ResumeService.getResumeDetails(allResumes[0].value);
        System.debug('Inside ResumeServiceTest.testGetResumeDetails, Testing coverage for getResumeDetails(resumeId) ' + resumeDetails);
        Test.stopTest();
        System.assertNotEquals(null, resumeDetails, 'resumeDetails should not be null');
        
    }
}