public with sharing class GODISService {

    final private static String CONFIRM_ORDER_CONFIG_NAME = 'GODIS_Confirm_Order';

    public static HttpResponse sendOrderConfirmRequest(Order o) {
        Interface__mdt config = Interface__mdt.getInstance(CONFIRM_ORDER_CONFIG_NAME);
        return HTTPService.sendRequest(
            config.Endpoint__c,
            null,
            createOrderConfirmReqJSONFromOrder(o),
            config.Method__c
        );
    }

    private static String createOrderConfirmReqJSONFromOrder(Order o) {
        return JSON.serialize(createOrderConfirmRequest(o));
    }

    private static GODISOrderConfirmRequest createOrderConfirmRequest(Order o) {
        GODISOrderConfirmRequest req = new GODISOrderConfirmRequest();
        req.accountNumber = o.Account.AccountNumber;
        req.orderNumber = o.OrderNumber;
        req.type = o.Type;
        req.status = o.Status;
        req.orderProducts = new List<GODISOrderConfirmRequest.GODISOrderProduct>();
        for (OrderItem oi : o.OrderItems) {
            GODISOrderConfirmRequest.GODISOrderProduct prd = new GODISOrderConfirmRequest.GODISOrderProduct();
            prd.name = oi.Product2.Name;
            prd.code = oi.Product2.ProductCode;
            prd.unitPrice = oi.UnitPrice;
            prd.quantity = oi.Quantity;
            req.orderProducts.add(prd);
        }
        return req;
    }
}