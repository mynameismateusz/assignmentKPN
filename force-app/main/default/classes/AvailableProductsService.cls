public with sharing class AvailableProductsService {

    /**
     * Get active PricebookEntries, related to Order's Pricebook
     * @param {Id} recordId: Id of an Order
     * @return {List<PricebookEntry>} - empty if Order doesn't have a Pricebook
     */
    public static List<PricebookEntry> getOrderAvailableProducts(Id orderId, Integer amount, Integer offset) {
        Order o = OrderSelector.getOrdersByIds(new Set<Id>{orderId})[0];
        return PricebookEntrySelector.getPricebookEntriesByPricebookId(o.Pricebook2Id, amount, offset);
    }

    /**
     * Get total amount of active PricebookEntries, related to Order's Pricebook
     * @param {String} orderId
     * @return {Integer} amount of PricebookEntries
     */
    public static Integer getOrderAvailableProductsCount(Id orderId) {
        Order o = OrderSelector.getOrdersByIds(new Set<Id>{orderId})[0];
        AggregateResult res = PricebookEntrySelector.getPricebookEntriesCountByPricebookId(o.Pricebook2Id);
        return (Integer) res.get('Amount');
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
            OrderItem toUpsert = orderItems[0];
            toUpsert.Quantity += item.Quantity;
            item = toUpsert;
        }
        return DMLService.upsertRecords(new List<OrderItem>{item}, true)[0];
    }
}