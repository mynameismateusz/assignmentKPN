public with sharing class AvailableProductsController extends AuraController {

    /**
     * Get active PricebookEntries, related to Order's Pricebook
     * @param {String} orderId: Id of an Order
     * @return {List<PricebookEntry>} Available PricebookEntries
     * @throws {AuraHandledException}
     */
    @AuraEnabled(Cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(String orderId, Integer amount, Integer offset) {
        validateId(orderId, Order.getSObjectType());
        try {
            return AvailableProductsService.getOrderAvailableProducts(orderId, amount, offset);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get OrderItems related to a given Order.
     * @param {String} orderId: Id of an Order
     * @param {Map<String, Object>} jsonOrderItem: OrderItem to insert
     * @return {List<OrderItem>} Related OrderItems
     * @throws {AuraHandledException}
     */
    @AuraEnabled(Cacheable=true)
    public static List<OrderItem> getOrderProducts(String orderId) {
        validateId(orderId, Order.getSObjectType());
        try {
            return AvailableProductsService.getOrderProductsByOrderId(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get total amount of active PricebookEntries, related to Order's Pricebook
     * @param {String} orderId
     * @return {Integer} amount of PricebookEntries
     * @throws {AuraHandledException}
     */
    @AuraEnabled(Cacheable=true)
    public static Integer getOrderAvailableProductsCount(String orderId) {
        validateId(orderId, Order.getSObjectType());
        try {
            return AvailableProductsService.getOrderAvailableProductsCount(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Add an Order Product.
     * @param {String} orderId: Id of an Order
     * @param {Map<String, Object>} jsonOrderItem: OrderItem to insert
     * @return {OrderItem} Upserted item
     * @throws {AuraHandledException} If upsert is unsuccesful
     */
    @AuraEnabled
    public static OrderItem addOrderItem(String orderId, Map<String, Object> jsonOrderItem) {
        validateId(orderId, Order.getSObjectType());
        OrderItem item = (OrderItem) deserializeSObjectJSON(jsonOrderItem, OrderItem.SObjectType);

        DMLService.DMLResult res = AvailableProductsService.addOrderItem(orderId, item);
        if (!res.getErrors().isEmpty()) throw new AuraHandledException(Label.ProductNotAddedErr);
        return (OrderItem) res.getRecord();
    }
}