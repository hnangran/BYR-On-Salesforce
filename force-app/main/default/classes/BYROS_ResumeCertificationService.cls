public with sharing class BYROS_ResumeCertificationService {

    @AuraEnabled
    public static List<Certification__c> getUnlinkedResumeCertifications(Id resumeId, Integer limitSize) {
        if (!Schema.sObjectType.Resume_Certification__c.isAccessible() || 
            !Schema.sObjectType.Certification__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access certification records.');
        }

        Set<Id> linkedCertIds = new Set<Id>();
        for (Resume_Certification__c rc : [
                SELECT Certification__c
                FROM Resume_Certification__c
                WHERE Resume__c = :resumeId
            ]) {
            linkedCertIds.add(rc.Certification__c);
        }
        
        List<Certification__c> results = [
                SELECT Id, Name, Issuer__c, Date_Achieved__c
                FROM Certification__c
                WHERE Id NOT IN :linkedCertIds
                ORDER BY CreatedDate DESC
                LIMIT :limitSize
            ];
            
        return results;
    }

    @AuraEnabled
    public static List<Certification__c> getResumeCertifications(Id resumeId) {
        if (!Schema.sObjectType.Resume_Certification__c.isAccessible() || 
            !Schema.sObjectType.Certification__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access certification records.');
        }
        
        Map<Id, Certification__c> certById = new Map<Id, Certification__c>();
        for (Resume_Certification__c rc : [
                SELECT Id, Certification__c, Certification__r.Name, 
                    Certification__r.Issuer__c, Certification__r.Date_Achieved__c
                FROM Resume_Certification__c
                WHERE Resume__c = :resumeId
            ]) {
            certById.put(rc.Certification__c, rc.Certification__r);
        }
        return certById.values();
    }

    @AuraEnabled
    public static void linkCertifications(Id resumeId, List<Id> certificationIds) {
        if (!Schema.sObjectType.Resume_Certification__c.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to link certification records.');
        }
        
        List<Resume_Certification__c> toInsert = new List<Resume_Certification__c>();
        for (Id certId : certificationIds) {
            toInsert.add(new Resume_Certification__c(Resume__c = resumeId, Certification__c = certId));
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
    
    @AuraEnabled
    public static void unlinkCertifications(Id resumeId, List<Id> certificationIds) {
        if (!Schema.sObjectType.Resume_Certification__c.isDeletable()) {
            throw new AuraHandledException('Insufficient permissions to unlink certification records.');
        }
        
        List<Resume_Certification__c> toDelete = [
                SELECT Id 
                FROM Resume_Certification__c
                WHERE Resume__c = :resumeId AND Certification__c IN :certificationIds
            ];
        if (!toDelete.isEmpty()) {
            delete toDelete;
        }
    }
}