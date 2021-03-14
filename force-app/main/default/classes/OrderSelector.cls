public with sharing class OrderSelector {

    public static List<Order> getOrdersByIds(Set<Id> orderIds) {
        return [
            SELECT Pricebook2Id, OrderNumber, Status, Type, Account.AccountNumber,
                (
                    SELECT Product2.Name, Product2.ProductCode, UnitPrice, Quantity
                    FROM OrderItems
                )
            FROM Order
            WHERE Id IN : orderIds
        ];
    }
}