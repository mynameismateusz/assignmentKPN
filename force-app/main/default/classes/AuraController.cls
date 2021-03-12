public virtual with sharing class AuraController {

    public static void validateId(Id recordId, SObjectType type) {
        isIdPopulated(recordId, type);
        isIdCorrectType(recordId, type);
    }

    private static void isIdPopulated(Id recordId, SObjectType type) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException(type.getDescribe().getLabel() + ' Id is empty');
        }
    }

    private static void isIdCorrectType(Id recordId, SObjectType type) {
        if (recordId.getSObjectType() != type) {
            throw new AuraHandledException('Provided Id is of an incorrect type');
        }
    }
}
