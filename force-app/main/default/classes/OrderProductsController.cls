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

    @AuraEnabled
    public static Order activateOrder(String orderId) {
        validateId(orderId, Order.getSObjectType());
        try {
            DMLService.DMLResult res = OrderProductsService.activateOrder(orderId);
            if (!res.getErrors().isEmpty()) throw new AuraHandledException(Label.OrderNotActivatedErr);
            return (Order) res.getRecord();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}