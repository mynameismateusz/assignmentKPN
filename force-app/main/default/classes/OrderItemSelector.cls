public with sharing class OrderItemSelector {

    public static List<OrderItem> getOrderItemsByOrderId(Id orderId) {
        return [
            SELECT UnitPrice, Quantity, TotalPrice, Product2.Name
            FROM OrderItem
            WHERE OrderId =: orderId
        ];
    }
}
