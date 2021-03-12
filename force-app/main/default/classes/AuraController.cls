public virtual with sharing class AuraController {

    /**
    * Check if given recordId is valid
     * @param {Id} recordId: Id of an SObject record
     * @param {SObjectType} type: Expected type of an SObject record
     */
    public static void validateId(Id recordId, SObjectType type) {
        isIdPopulated(recordId, type);
        isIdCorrectType(recordId, type);
    }

    /**
     * Deserialize SObject JSON into an SObject instance
     * @param {Object} json: JSON to parse
     * @param {SObjectType} sobjType: Type to deserialize the JSON to
     * @return {SObject} Deserialized SObject instance
     * @throws {AuraHandledException} If if JSON can't be deserialized
     */
    public static SObject deserializeSObjectJSON(Object jsonObj, SObjectType sobjType) {
        String sobjTypeName = sobjType.getDescribe().getName();
        try {
            return (SObject) JSON.deserialize(JSON.serialize(jsonObj), Type.forName(sobjTypeName));
        } catch (Exception e) {
            throw new AuraHandledException('Provided ' + sobjTypeName + ' is incorrect');
        }
    }

    /**
     * Check if given recordId is not blank
     * @param {Id} recordId: Id of an SObject record
     * @param {SObjectType} type: Expected type of an SObject record
     * @throws {AuraHandledException} If given recordId is blank
     */
    private static void isIdPopulated(Id recordId, SObjectType type) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException(type.getDescribe().getLabel() + ' Id is empty');
        }
    }

    /**
     * Evaluate if given recordId belongs to the correct SObject Type
     * @param {Id} recordId: Id of an SObject record
     * @param {SObjectType} type: Expected type of an SObject record
     * @throws {AuraHandledException} If given recordId does not match the expected SObjectType
     */
    private static void isIdCorrectType(Id recordId, SObjectType type) {
        if (recordId.getSObjectType() != type) {
            throw new AuraHandledException('Provided Id is of an incorrect type');
        }
    }
}
