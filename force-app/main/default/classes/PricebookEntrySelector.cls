public with sharing class PricebookEntrySelector {

    public static List<PricebookEntry> getPricebookEntriesByPricebookId(Id pricebookId, Integer amount, Integer offset) {
        return [
            SELECT Name, UnitPrice, Product2Id, Product2.Name
            FROM PricebookEntry
            WHERE Pricebook2Id =: priceBookId
            AND IsActive = TRUE
            ORDER BY Name
            LIMIT : amount
            OFFSET : offset
        ];
    }

    public static AggregateResult getPricebookEntriesCountByPricebookId(Id pricebookId) {
        return [
            SELECT COUNT(Id) Amount
            FROM PricebookEntry
            WHERE Pricebook2Id =: priceBookId
        ];
    }
}