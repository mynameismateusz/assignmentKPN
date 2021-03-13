public with sharing class AvailableProductsService {

    /**
     * Get active PricebookEntries, related to Order's Pricebook
     * @param {Id} recordId: Id of an Order
     * @return {List<PricebookEntry>} - null if Order doesn't have a Pricebook
     */
    public static List<PricebookEntry> getAvailableProducts(Id orderId) {
        Map<Id, Order> orders = new Map<Id, Order>(OrderSelector.getOrdersByIds(new Set<Id>{orderId}));
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
        return OrderItemSelector.getOrderItemsByOrderId(orderId);
    }

    /**
     * Upsert an Order Product.
     * If Order already has given Product, then quantity of an existing Order Product is incremented by one.
     * If Order does not have such Product yet, it simply inserts a new OrderItem.
     * @param {Id} recordId: Id of an Order
     * @param {OrderItem} item: OrderItem to insert
     * @return {DMLService.DMLResult} Result of an upsert + the upserted item
     */
    public static DMLService.DMLResult addOrderItem(Id orderId, OrderItem item) {
        List<OrderItem> orderItems = OrderItemSelector.getOrderItemsByOrderAndProductId(orderId, item.Product2Id);
        if (!orderItems.isEmpty()) {
            item = orderItems[0];
            item.Quantity ++;
        }
        return DMLService.upsertRecords(new List<OrderItem>{item}, true)[0];
    }
}
