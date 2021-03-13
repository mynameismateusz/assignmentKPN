@IsTest
private class PricebookEntrySelector_Test {

    @TestSetup
    static void makeData(){
        Pricebook2 pricebook = TestDataFactory.getStandardPricebook();
        Map<Id, Product2> products = new Map<Id, Product2>(TestDataFactory.insertProducts(10));
        List<PricebookEntry> entries = TestDataFactory.insertPricebookEntries(products.keySet(), pricebook.Id);
    }

    @IsTest
    static void getPricebookEntriesByPricebookId_POS() {
        //GIVEN
        final Pricebook2 PRICEBOOK = [SELECT Id, (SELECT Id FROM PricebookEntries) FROM Pricebook2 WHERE Id =: Test.getStandardPricebookId()];

        //WHEN
        Test.startTest();
        final List<PricebookEntry> ENTRIES = PricebookEntrySelector.getPricebookEntriesByPricebookId(PRICEBOOK.Id);
        Test.stopTest();

        System.assertEquals(PRICEBOOK.PricebookEntries.size(), ENTRIES.size(), 'Amount of returned entries should match');
    }

    @IsTest
    static void getPricebookEntriesByPricebookId_NEG() {
        //GIVEN
        final Pricebook2 NEW_PRICEBOOK = TestDataFactory.insertPricebooks(1)[0];

        //WHEN
        Test.startTest();
        final List<PricebookEntry> ENTRIES = PricebookEntrySelector.getPricebookEntriesByPricebookId(NEW_PRICEBOOK.Id);
        Test.stopTest();

        System.assertEquals(true, ENTRIES.isEmpty(), 'No entries should be returned');
    }
}
