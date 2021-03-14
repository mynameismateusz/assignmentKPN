public with sharing class GODISOrderConfirmRequest {
    public String accountNumber;
    public String orderNumber;
    public String type;
    public String status;
    public GODISOrderProduct[] orderProducts;

    public class GODISOrderProduct {
        public String name;
        public String code;
        public Decimal unitPrice;
        public Decimal quantity;
    }
}