public with sharing class OrderProductsService {

    final private static String ORDER_STATUS_ACTIVATED = 'Activated';

    /**
     * Get Order Products related to an Order
     * @param {Id} recordId: Id of an Order
     * @return {List<OrderItem>}
     */
    public static List<OrderItem> getOrderProductsByOrderId(Id orderId) {
        return OrderItemSelector.getOrderItemsByOrderId(orderId);
    }

    /**
     * Get Order Products related to an Order
     * @param {Id} recordId: Id of an Order
     * @return {List<OrderItem>}
     */
    public static List<DMLService.DMLResult> activateOrders(Set<Id> orderIds) {
        List<Order> orders = OrderSelector.getOrdersByIds(orderIds);
        for (Order o : orders) {
            o.Status = ORDER_STATUS_ACTIVATED;
        }
        return DMLService.upsertRecords(orders, true);
    }
}