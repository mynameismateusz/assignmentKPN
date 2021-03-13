public with sharing class OrderSelector {

    public static List<Order> getOrdersByIds(Set<Id> orderIds) {
        return [
            SELECT Pricebook2Id
            FROM Order
            WHERE Id IN : orderIds
        ];
    }
}