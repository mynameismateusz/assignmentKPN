public with sharing class OrderSelector {

    public static Map<Id, Order> getOrdersByIds(Set<Id> orderIds) {
        return new Map<Id, Order> ([
            SELECT Pricebook2Id
            FROM Order
            WHERE Id IN : orderIds
        ]);
    }
}
