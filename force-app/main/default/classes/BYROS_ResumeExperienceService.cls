public with sharing class BYROS_ResumeExperienceService {

    @AuraEnabled
    public static List<Work_Experience__c> getUnlinkedResumeExperiences(Id resumeId, Integer limitSize) {
        if (!Schema.sObjectType.Resume_Experience__c.isAccessible() || 
            !Schema.sObjectType.Work_Experience__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access work experience records.');
        }

        Set<Id> linkedExpIds = new Set<Id>();
        for (Resume_Experience__c re : [
                SELECT Work_Experience__c
                FROM Resume_Experience__c
                WHERE Resume__c = :resumeId
            ]) {
            linkedExpIds.add(re.Work_Experience__c);
        }
        
        List<Work_Experience__c> results = [
                SELECT Id, Name, Company__c, Role__c, Location__c, From_Date__c, To_Date__c, Responsibilities__c
                FROM Work_Experience__c
                WHERE Id NOT IN :linkedExpIds
                ORDER BY CreatedDate DESC
                LIMIT :limitSize
            ];
            
        return results;
    }

    @AuraEnabled
    public static List<Map<String, Object>> getResumeExperiences(Id resumeId) {
        if (!Schema.sObjectType.Resume_Experience__c.isAccessible() || 
            !Schema.sObjectType.Work_Experience__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access work experience records.');
        }
        
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Resume_Experience__c re : [
                SELECT Id, Work_Experience__c, Responsibilities__c,
                    Work_Experience__r.Id, Work_Experience__r.Name, 
                    Work_Experience__r.Company__c, Work_Experience__r.Role__c,
                    Work_Experience__r.Location__c, Work_Experience__r.From_Date__c,
                    Work_Experience__r.To_Date__c
                FROM Resume_Experience__c
                WHERE Resume__c = :resumeId
            ]) {
            Map<String, Object> exp = new Map<String, Object>();
            exp.put('Id', re.Work_Experience__r.Id);
            exp.put('Name', re.Work_Experience__r.Name);
            exp.put('Company__c', re.Work_Experience__r.Company__c);
            exp.put('Role__c', re.Work_Experience__r.Role__c);
            exp.put('Location__c', re.Work_Experience__r.Location__c);
            exp.put('From_Date__c', re.Work_Experience__r.From_Date__c);
            exp.put('To_Date__c', re.Work_Experience__r.To_Date__c);
            exp.put('ResumeExperienceId', re.Id);
            exp.put('Responsibilities', re.Responsibilities__c);
            results.add(exp);
        }
        return results;
    }

    @AuraEnabled
    public static void linkExperiences(Id resumeId, List<Id> experienceIds) {
        if (!Schema.sObjectType.Resume_Experience__c.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to link work experience records.');
        }
        
        List<Resume_Experience__c> toInsert = new List<Resume_Experience__c>();
        for (Id expId : experienceIds) {
            toInsert.add(new Resume_Experience__c(Resume__c = resumeId, Work_Experience__c = expId));
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
    
    @AuraEnabled
    public static void unlinkExperiences(Id resumeId, List<Id> experienceIds) {
        if (!Schema.sObjectType.Resume_Experience__c.isDeletable()) {
            throw new AuraHandledException('Insufficient permissions to unlink work experience records.');
        }
        
        List<Resume_Experience__c> toDelete = [
                SELECT Id 
                FROM Resume_Experience__c
                WHERE Resume__c = :resumeId AND Work_Experience__c IN :experienceIds
            ];
        if (!toDelete.isEmpty()) {
            delete toDelete;
        }
    }

    @AuraEnabled
    public static void updateResumeExperienceResponsibilities(Id resumeExperienceId, String responsibilities) {
        if (!Schema.sObjectType.Resume_Experience__c.isUpdateable()) {
            throw new AuraHandledException('Insufficient permissions to update work experience records.');
        }
        
        Resume_Experience__c re = new Resume_Experience__c(
            Id = resumeExperienceId,
            Responsibilities__c = responsibilities
        );
        update re;
    }

    @AuraEnabled
    public static void updateWorkExperienceResponsibilities(Id workExperienceId, String responsibilities) {
        if (!Schema.sObjectType.Work_Experience__c.isUpdateable()) {
            throw new AuraHandledException('Insufficient permissions to update work experience records.');
        }
        
        Work_Experience__c we = new Work_Experience__c(
            Id = workExperienceId,
            Responsibilities__c = responsibilities
        );
        update we;
    }
}