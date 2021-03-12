public with sharing class AvailableProductsService {

    public static List<PricebookEntry> getAvailableProducts(Id orderId) {
        Map<Id, Order> orders = OrderSelector.getOrdersByIds(new Set<Id>{orderId});
        Id pricebookId = orders.get(orderId)?.Pricebook2Id;
        if (pricebookId == null) return null;
        return PricebookEntrySelector.getPricebookEntriesByPricebookId(pricebookId);
    }

    public static List<OrderItem> getOrderProductsByOrderId(Id orderId) {
        return OrderProductsService.getOrderProductsByOrderId(orderId);
    }
}
