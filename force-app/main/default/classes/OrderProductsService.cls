public with sharing class OrderProductsService {

    final private static String ORDER_STATUS_ACTIVATED = 'Activated';
    public class OrderProductsServiceException extends Exception {}

    /**
     * Get Order Products related to an Order
     * @param {Id} recordId: Id of an Order
     * @return {List<OrderItem>}
     */
    public static List<OrderItem> getOrderProductsByOrderId(Id orderId) {
        return OrderItemSelector.getOrderItemsByOrderId(orderId);
    }

    /**
     * Activate an Order. It confirms the Order in an external system.
     * If the confirmation is successful, the Order's status is updated.
     * @param {Id} recordId: Id of an Order
     * @return {DMLService.DMLResult} result of the Order update
     */
    public static DMLService.DMLResult activateOrder(Id orderId) {
        Order o = OrderSelector.getOrdersByIds(new Set<Id>{orderId})[0];
        o.Status = ORDER_STATUS_ACTIVATED;

        //Send confirmation request to the 'GODIS' external system
        HttpResponse httpRes;
        try {
            httpRes = confirmOrderInExternalSystem(o);
        } catch (System.CalloutException ex) {
            throw new OrderProductsServiceException(Label.OrderConfirmationFailErr);
        }
        if (httpRes.getStatusCode() != 200) {
            throw new OrderProductsServiceException(Label.OrderConfirmationFailErr);
        }

        //If the request was successful => activate the order
        DMLService.DMLResult res = DMLService.upsertRecords(new List<Order>{o}, true)[0];
        return res;
    }


    /**
     * Send a request to confirm Order in the external system
     * @param {Order} order to confirm
     * @return {HttpResponse} external system response
     */
    private static HttpResponse confirmOrderInExternalSystem(Order o) {
        return GODISService.sendOrderConfirmRequest(o);
    }
}