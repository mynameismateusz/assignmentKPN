public with sharing class AvailableProductsController extends AuraController {

    /**
     * Get active PricebookEntries, related to Order's Pricebook
     * @param {Id} orderId: Id of an Order
     * @return {List<PricebookEntry>} Available PricebookEntries
     * @throws {AuraHandledException}
     */
    @AuraEnabled(Cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(Id orderId) {
        validateId(orderId, Order.getSObjectType());
        try {
            return AvailableProductsService.getAvailableProducts(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get OrderItems related to a given Order.
     * @param {Id} orderId: Id of an Order
     * @param {Map<String, Object>} jsonOrderItem: OrderItem to insert
     * @return {List<OrderItem>} Related OrderItems
     * @throws {AuraHandledException}
     */
    @AuraEnabled(Cacheable=true)
    public static List<OrderItem> getOrderProducts(Id orderId) {
        validateId(orderId, Order.getSObjectType());
        try {
            return AvailableProductsService.getOrderProductsByOrderId(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Add an Order Product.
     * If Order already has given Product, then quantity of an existing Order Product is incremented by one.
     * If Order does not have such Product yet, it simply inserts a new OrderItem.
     * @param {Id} orderId: Id of an Order
     * @param {Map<String, Object>} jsonOrderItem: OrderItem to insert
     * @return {OrderItem} Upserted item
     * @throws {AuraHandledException} If upsert is unsuccesful
     */
    @AuraEnabled
    public static OrderItem addOrderItem(Id orderId, Map<String, Object> jsonOrderItem) {
        validateId(orderId, Order.getSObjectType());
        OrderItem item = (OrderItem) deserializeSObjectJSON(jsonOrderItem, OrderItem.SObjectType);

        DMLService.DMLResult res = AvailableProductsService.addOrderItem(orderId, item);
        if (!res.getErrors().isEmpty()) throw new AuraHandledException('Product was not added successfully');
        return (OrderItem) res.getRecord();
    }
}
