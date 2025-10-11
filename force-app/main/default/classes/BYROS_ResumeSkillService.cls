public with sharing class BYROS_ResumeSkillService {

    @AuraEnabled
    public static List<Skill__c> getUnlinkedResumeSkills(Id resumeId, Integer limitSize) {
        if (!Schema.sObjectType.Resume_Skill__c.isAccessible() || 
            !Schema.sObjectType.Skill__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access skill records.');
        }

        Set<Id> linkedSkillIds = new Set<Id>();
        for (Resume_Skill__c rs : [
                SELECT Skill__c
                FROM Resume_Skill__c
                WHERE Resume__c = :resumeId
            ]) {
            linkedSkillIds.add(rs.Skill__c);
        }
        
        List<Skill__c> results = [
                SELECT Id, Name
                FROM Skill__c
                WHERE Id NOT IN :linkedSkillIds
                ORDER BY CreatedDate DESC
                LIMIT :limitSize
            ];
            
        return results;
    }

    @AuraEnabled
    public static List<Skill__c> getResumeSkills(Id resumeId) {
        if (!Schema.sObjectType.Resume_Skill__c.isAccessible() || 
            !Schema.sObjectType.Skill__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access skill records.');
        }
        
        Map<Id, Skill__c> skillById = new Map<Id, Skill__c>();
        for (Resume_Skill__c rs : [
                SELECT Id, Skill__c, Skill__r.Name
                FROM Resume_Skill__c
                WHERE Resume__c = :resumeId
            ]) {
            skillById.put(rs.Skill__c, rs.Skill__r);
        }
        return skillById.values();
    }

    @AuraEnabled
    public static void linkSkills(Id resumeId, List<Id> skillIds) {
        if (!Schema.sObjectType.Resume_Skill__c.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to link skill records.');
        }
        
        List<Resume_Skill__c> toInsert = new List<Resume_Skill__c>();
        for (Id skillId : skillIds) {
            toInsert.add(new Resume_Skill__c(Resume__c = resumeId, Skill__c = skillId));
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
    
    @AuraEnabled
    public static void unlinkSkills(Id resumeId, List<Id> skillIds) {
        if (!Schema.sObjectType.Resume_Skill__c.isDeletable()) {
            throw new AuraHandledException('Insufficient permissions to unlink skill records.');
        }
        
        List<Resume_Skill__c> toDelete = [
                SELECT Id 
                FROM Resume_Skill__c
                WHERE Resume__c = :resumeId AND Skill__c IN :skillIds
            ];
        if (!toDelete.isEmpty()) {
            delete toDelete;
        }
    }
}