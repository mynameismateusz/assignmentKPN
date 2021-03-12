public with sharing class AvailableProductsService {

    /**
     * Get active PricebookEntries, related to Order's Pricebook
     * @param {Id} recordId: Id of an Order
     * @return {List<PricebookEntry>} - null if Order doesn't have a Pricebook
     */
    public static List<PricebookEntry> getAvailableProducts(Id orderId) {
        Map<Id, Order> orders = OrderSelector.getOrdersByIds(new Set<Id>{orderId});
        Id pricebookId = orders.get(orderId)?.Pricebook2Id;
        if (pricebookId == null) return null;
        return PricebookEntrySelector.getPricebookEntriesByPricebookId(pricebookId);
    }

    /**
     * Get Order Products related to an Order
     * @param {Id} recordId: Id of an Order
     * @return {List<OrderItem>}
     */
    public static List<OrderItem> getOrderProductsByOrderId(Id orderId) {
        return OrderProductsService.getOrderProductsByOrderId(orderId);
    }
}
