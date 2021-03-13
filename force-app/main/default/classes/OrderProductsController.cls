public with sharing class OrderProductsController extends AuraController {

    @AuraEnabled(Cacheable=true)
    public static List<OrderItem> getOrderProducts(String orderId) {
        validateId(orderId, Order.getSObjectType());
        try {
            return OrderProductsService.getOrderProductsByOrderId(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
