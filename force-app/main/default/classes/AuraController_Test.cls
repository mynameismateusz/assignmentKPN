@IsTest
private class AuraController_Test {

    @TestSetup
    static void setup() {
        insert new Contact(
            LastName = 'TestName'
        );
    }

    static Map<String, Object> parseContactData(Contact con) {
        return new Map<String,Object>{
            'Id' => con.Id,
            'LastName' => con.LastName
        };
    }

    @IsTest
    static void validateId_POS() {
        //GIVEN
        final Contact CON = [SELECT Id FROM Contact LIMIT 1];
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
            AuraController.validateId(CON.Id, Contact.SObjectType);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(false, exceptionThrown, 'Exception should not be thrown');
    }

    @IsTest
    static void deserializeSObjectJSON_POS() {
        //GIVEN
        final Contact CON = [SELECT LastName FROM Contact LIMIT 1];
        final Map<String, Object> PARSED_CONTACT = parseContactData(CON);
        Boolean exceptionThrown = false;
        Contact deserialized;

        //WHEN
        Test.startTest();
        try {
            deserialized = (Contact) AuraController.deserializeSObjectJSON(PARSED_CONTACT, Contact.SObjectType);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(false, exceptionThrown, 'Exception should not be thrown');
        System.assertEquals(CON.Id, deserialized.Id, 'Id field should be populated correctly');
        System.assertEquals(CON.LastName, deserialized.LastName, 'LastName field should be populated correctly');
    }

    @IsTest
    static void deserializeSObjectJSON_NEG() {
        //GIVEN
        final Map<String, Object> PARSED_DATA = null;
        final SObjectType SOBJ_TYPE = null;
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
            AuraController.deserializeSObjectJSON(PARSED_DATA, SOBJ_TYPE);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(true, exceptionThrown, 'Exception should be thrown');
    }

    @IsTest
    static void isIdPopulated_POS() {
        //GIVEN
        final Contact CON = [SELECT Id FROM Contact LIMIT 1];
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
            AuraController.isIdPopulated(CON.Id, Contact.SObjectType);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(false, exceptionThrown, 'Exception should not be thrown when Id is populated');
    }

    @IsTest
    static void isIdPopulated_NEG() {
        //GIVEN
        final String BLANK_RECORD_ID = ' ';
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
            AuraController.isIdPopulated(BLANK_RECORD_ID, Contact.SObjectType);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(true, exceptionThrown, 'Exception should be thrown when Id is blank');
    }

    @IsTest
    static void isId_POS() {
        //GIVEN
        final Contact CON = [SELECT Id FROM Contact LIMIT 1];
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
            AuraController.isId(CON.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(false, exceptionThrown, 'Exception should not be thrown when Id is correct');
    }

    @IsTest
    static void isId_NEG() {
        //GIVEN
        final String INCORRECT_ID = 'NotAnId';
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
            AuraController.isId(INCORRECT_ID);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(true, exceptionThrown, 'Exception should be thrown when Id is incorrect');
    }

    @IsTest
    static void isIdCorrectType_POS() {
        //GIVEN
        final Contact CON = [SELECT Id FROM Contact LIMIT 1];
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
            AuraController.isIdCorrectType(CON.Id, Contact.SObjectType);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(false, exceptionThrown, 'Exception should not be thrown when Id is of a correct type');
    }

    @IsTest
    static void isIdCorrectType_NEG() {
        //GIVEN
        final Contact CON = [SELECT Id FROM Contact LIMIT 1];
        Boolean exceptionThrown = false;

        //WHEN
        Test.startTest();
        try {
            AuraController.isIdCorrectType(CON.Id, Account.SObjectType);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        //THEN
        System.assertEquals(true, exceptionThrown, 'Exception should be thrown when Id is of an incorrect type');
    }
}
