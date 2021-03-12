public with sharing class OrderProductsService {

    public static List<OrderItem> getOrderProductsByOrderId(Id orderId) {
        return OrderItemSelector.getOrderItemsByOrderId(orderId);
    }
}
