// Anonymous Apex: Query all fields for an object via Schema
// Usage:
// - Set objectApiName, whereClause, and recordLimit as needed.
// - Run with: sf apex run -f scripts/queryAllFields.apex
//
// Notes:
// - SOQL does not support SELECT *. This script builds the field list via Schema.
// - Filters to fields the running user can access and that are not formula-only.
// - For very wide objects, the constructed SOQL may hit length limits; adjust filters if needed.

String objectApiName = 'Education__c'; // e.g., 'Account', 'Contact', 'Resume__c'
String whereClause   = '';          // e.g., 'WHERE CreatedDate = THIS_MONTH'
Integer recordLimit  = 50;          // Recommended to keep reasonable limits

Schema.SObjectType sType = Schema.getGlobalDescribe().get(objectApiName);
if (sType == null) {
    System.debug(LoggingLevel.ERROR, 'Invalid sObject: ' + objectApiName);
} else {
    Schema.DescribeSObjectResult d = sType.getDescribe();
    Map<String, Schema.SObjectField> fields = d.fields.getMap();

    List<String> fieldNames = new List<String>();
    for (String apiName : fields.keySet()) {
        Schema.DescribeFieldResult f = fields.get(apiName).getDescribe();
        // Include fields that are accessible to the running user.
        // Exclude calculated-only fields to reduce issues when selecting.
        if (f.isAccessible() && !f.isCalculated()) {
            fieldNames.add(apiName);
        }
    }
    fieldNames.sort();

    if (fieldNames.isEmpty()) {
        System.debug('No accessible fields found for ' + objectApiName);
    } else {
        String soql =
            'SELECT ' +
            String.join(fieldNames, ', ') +
            ' FROM ' + objectApiName +
            (String.isBlank(whereClause) ? '' : ' ' + whereClause) +
            ' LIMIT ' + recordLimit;

        System.debug('Executing SOQL: ' + soql);

        List<SObject> rows = Database.query(soql);
        System.debug('Rows returned: ' + rows.size());

        Integer idx = 0;
        for (SObject r : rows) {
            Map<String, Object> rowMap = new Map<String, Object>();
            for (String fName : fieldNames) {
                rowMap.put(fName, r.get(fName));
            }
            System.debug('Row ' + (++idx) + ': ' + JSON.serialize(rowMap));
        }
    }
}
