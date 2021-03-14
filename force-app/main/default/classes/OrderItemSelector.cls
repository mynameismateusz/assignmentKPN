public with sharing class OrderItemSelector {

    public static List<OrderItem> getOrderItemsByOrderId(Id orderId) {
        return [
            SELECT
                UnitPrice, Quantity, TotalPrice, Product2.Name,
                PricebookEntry.Name, PricebookEntry.UnitPrice, PricebookEntry.Product2.Name
            FROM OrderItem
            WHERE OrderId =: orderId
        ];
    }

    public static List<OrderItem> getOrderItemsByOrderAndProductId(Id orderId, Id product2Id) {
        return [
            SELECT UnitPrice, Quantity, TotalPrice, Product2.Name, OrderId
            FROM OrderItem
            WHERE OrderId =: orderId
            AND Product2Id =: product2Id
        ];
    }
}