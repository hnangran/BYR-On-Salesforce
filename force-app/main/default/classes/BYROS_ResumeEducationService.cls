public with sharing class BYROS_ResumeEducationService {

    private static final String EDUCATION_SEARCH_LIMIT = '10';
    private static final String EDUCATION_OBJECT = 'Education__c';

    @AuraEnabled(cacheable=true)
    public static List<Education__c> getUnlinkedResumeEducations(Id resumeId, Integer limitSize) {
        // Validate CRUD permissions
        if (!Schema.sObjectType.Resume_Education__c.isAccessible() || 
            !Schema.sObjectType.Education__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access education records.');
        }

        // Get Education records not yet linked to the given Resume
        Set<Id> linkedEduIds = new Set<Id>();
        for (Resume_Education__c re : [
                SELECT Education__c
                FROM Resume_Education__c
                WHERE Resume__c = :resumeId
            ]) {
            linkedEduIds.add(re.Education__c);

        }
        List<Education__c> results = [
                SELECT Id, Name, Institution_Name__c, Degree_Type__c, Field_of_Study__c, Date_Achieved__c
                FROM Education__c
                WHERE Id NOT IN :linkedEduIds
                ORDER BY CreatedDate DESC
                LIMIT :limitSize
            ];
            
        return results;

    }

    @AuraEnabled(cacheable=true)
    public static List<Education__c> getResumeEducations(Id resumeId) {
        // Validate CRUD permissions
        if (!Schema.sObjectType.Resume_Education__c.isAccessible() || 
            !Schema.sObjectType.Education__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access education records.');
        }
        
        Map<Id, Education__c> eduById = new Map<Id, Education__c>();
        for (Resume_Education__c re : [
                SELECT Id, Education__c, Education__r.Name, 
                    Education__r.Institution_Name__c, Education__r.Degree_Type__c, 
                    Education__r.Field_of_Study__c, Education__r.Date_Achieved__c
                FROM Resume_Education__c
                WHERE Resume__c = :resumeId
            ]) {
            eduById.put(re.Education__c, re.Education__r);
        }
        return eduById.values();
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAccessibleEducationColumns() {
        List<Map<String, String>> columns = new List<Map<String, String>>();
        Schema.DescribeSObjectResult eduDescribe = Education__c.SObjectType.getDescribe();
        for (Schema.SObjectField field : eduDescribe.fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.isAccessible() && fieldDescribe.isCreateable() && fieldDescribe.isUpdateable()) {
                Map<String, String> col = new Map<String, String>();
                col.put('label', fieldDescribe.getLabel());
                col.put('fieldName', fieldDescribe.getName());
                col.put('type', fieldDescribe.getType().name());
                columns.add(col);
            }
        }
        return columns;
    }

    @AuraEnabled
    public static void linkEducations(Id resumeId, List<Id> educationIds) {
        // Validate CRUD permissions
        if (!Schema.sObjectType.Resume_Education__c.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to link education records.');
            
        }
        List<Resume_Education__c> toInsert = new List<Resume_Education__c>();
        for (Id eduId : educationIds) {
            toInsert.add(new Resume_Education__c(Resume__c = resumeId, Education__c = eduId));
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
            
        }
        
    }
    
    @AuraEnabled
    public static void unlinkEducations(Id resumeId, List<Id> educationIds) {
        // Validate CRUD permissions
        if (!Schema.sObjectType.Resume_Education__c.isDeletable()) {
            throw new AuraHandledException('Insufficient permissions to unlink education records.');


        }
        List<Resume_Education__c> toDelete = new List<Resume_Education__c>();
        for (Resume_Education__c re : [
                SELECT Id 
                FROM Resume_Education__c
                WHERE Resume__c = :resumeId AND Education__c IN :educationIds
            ]) {
            toDelete.add(re);
        }
        if (!toDelete.isEmpty()) {
            delete toDelete;

        }
    }


}