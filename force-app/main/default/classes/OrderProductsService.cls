public with sharing class OrderProductsService {

    public static List<OrderItem> getOrderProducts(Id orderId) {
        return [
            SELECT UnitPrice, Quantity, TotalPrice, Product2.Name
            FROM OrderItem
            WHERE OrderId =: orderId
        ];
    }
}
