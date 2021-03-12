public with sharing class AvailableProductsService {

    public static List<PricebookEntry> getAvailableProducts(Id orderId) {
        Map<Id, Order> orders = getOrdersByIds(new Set<Id>{orderId});
        Id pricebookId = orders.get(orderId)?.Pricebook2Id;
        if (pricebookId == null) return null;
        return getPricebookEntriesByPricebookId(pricebookId);
    }

    private static Map<Id, Order> getOrdersByIds(Set<Id> orderIds) {
        return new Map<Id, Order> ([
            SELECT Pricebook2Id
            FROM Order
            WHERE Id IN : orderIds
        ]);
    }

    private static List<PricebookEntry> getPricebookEntriesByPricebookId(Id pricebookId) {
        return [
            SELECT Name, UnitPrice, Product2Id, Product2.Name
            FROM PricebookEntry
            WHERE Pricebook2Id =: priceBookId
            AND IsActive = TRUE
            ORDER BY Name
        ];
    }
}
