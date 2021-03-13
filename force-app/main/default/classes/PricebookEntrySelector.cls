public with sharing class PricebookEntrySelector {

    public static List<PricebookEntry> getPricebookEntriesByPricebookId(Id pricebookId) {
        return [
            SELECT Name, UnitPrice, Product2Id, Product2.Name
            FROM PricebookEntry
            WHERE Pricebook2Id =: priceBookId
            AND IsActive = TRUE
            ORDER BY Name
        ];
    }
}