public with sharing class AvailableProductsController extends AuraController {

    @AuraEnabled(Cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(Id orderId) {
        validateId(orderId, Order.getSObjectType());
        try {
            return AvailableProductsService.getAvailableProducts(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<OrderItem> getOrderProducts(Id orderId) {
        validateId(orderId, Order.getSObjectType());
        try {
            return AvailableProductsService.getOrderProductsByOrderId(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
