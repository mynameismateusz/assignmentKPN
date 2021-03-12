public with sharing class OrderProductsController {

    @AuraEnabled(Cacheable=true)
    public static List<OrderItem> getOrderProducts(Id orderId) {
        if (String.isBlank(orderId)) {
            throw new AuraHandledException('Order Id is empty');
        }
        try {
            return OrderProductsService.getOrderProducts(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
