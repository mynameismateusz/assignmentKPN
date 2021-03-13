public virtual with sharing class AuraController {

    /**
    * Check if given recordId is valid
     * @param {String} recordId: Id of an SObject record
     * @param {SObjectType} type: Expected type of an SObject record
     */
    public static void validateId(String recordId, SObjectType type) {
        isIdPopulated(recordId, type);
        isId(recordId);
        isIdCorrectType(recordId, type);
    }

    /**
     * Deserialize SObject JSON into an SObject instance
     * @param {Map<String, Object>} parsedData: Data to deserialize
     * @param {SObjectType} sobjType: Type to deserialize the JSON to
     * @return {SObject} Deserialized SObject instance
     * @throws {AuraHandledException} If if JSON can't be deserialized
     */
    public static SObject deserializeSObjectJSON(Map<String, Object> parsedData, SObjectType sobjType) {
        String sobjTypeName;
        try {
            sobjTypeName = sobjType.getDescribe().getName();
            return (SObject) JSON.deserialize(JSON.serialize(parsedData), Type.forName(sobjTypeName));
        } catch (Exception e) {
            throw new AuraHandledException(
                String.format(Label.ObjectIncorrectErr, new List<String>{sobjTypeName})
            );
        }
    }

    /**
     * Check if given recordId is not blank
     * @param {String} recordId: Id of an SObject record
     * @param {SObjectType} type: Expected type of an SObject record
     * @throws {AuraHandledException} If given recordId is blank
     */
    @TestVisible
    private static void isIdPopulated(String recordId, SObjectType type) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException(
                String.format(Label.IdEmptyErr, new List<String>{type.getDescribe().getLabel()})
            );
        }
    }

    @TestVisible
    private static void isId(String recordId) {
        if (!(recordId instanceOf Id)) {
            throw new AuraHandledException(Label.NotAnIdErr);
        }
    }

    /**
     * Evaluate if given recordId belongs to the correct SObject Type
     * @param {Id} recordId: Id of an SObject record
     * @param {SObjectType} type: Expected type of an SObject record
     * @throws {AuraHandledException} If given recordId does not match the expected SObjectType
     */
    @TestVisible
    private static void isIdCorrectType(Id recordId, SObjectType type) {
        if (recordId.getSObjectType() != type) {
            throw new AuraHandledException(Label.IdIncorrectTypeErr);
        }
    }
}
