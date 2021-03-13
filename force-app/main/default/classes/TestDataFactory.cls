@IsTest
public class TestDataFactory {

    private static Integer TEST_PRICE = 20;
    private static Integer TEST_QUANTITY = 1;
    private static String ORDER_DEFAULT_STATUS = 'Draft';

    public static List<Product2> insertProducts(Integer amount) {
        List<Product2> products = createProducts(amount);
        insert products;
        return products;
    }

    public static List<Product2> createProducts(Integer amount) {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < amount; i++) {
            products.add(new Product2(
                Name = generateRandomString(12) + i,
                isActive = true
            ));
        }
        return products;
    }

    public static Pricebook2 getStandardPricebook() {
        Pricebook2 pricebook = new Pricebook2(
            isActive = true,
            Id = Test.getStandardPricebookId()
        );
        update pricebook;
        return pricebook;
    }

    public static List<Pricebook2> insertPricebooks(Integer amount) {
        List<Pricebook2> pricebooks = createPricebooks(amount);
        insert pricebooks;
        return pricebooks;
    }

    public static List<Pricebook2> createPricebooks(Integer amount) {
        List<Pricebook2> pricebooks = new List<Pricebook2>();
        for (Integer i = 0; i < amount; i++) {
            pricebooks.add(new Pricebook2(
                Name = generateRandomString(12) + i,
                isActive = true
            ));
        }
        return pricebooks;
    }

    public static List<PricebookEntry> insertPricebookEntries(Set<Id> productIds, Id pricebookId) {
        List<PricebookEntry> entries = createPricebookEntries(productIds, pricebookId);
        insert entries;
        return entries;
    }

    public static List<PricebookEntry> createPricebookEntries(Set<Id> productIds, Id pricebookId) {
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (Id productId : productIds) {
            entries.add(new PricebookEntry(
                Product2Id = productId,
                Pricebook2Id = pricebookId,
                isActive = true,
                UnitPrice = TEST_PRICE
            ));
        }
        return entries;
    }

    public static List<Account> insertAccounts(Integer amount) {
        List<Account> accounts = createAccounts(amount);
        insert accounts;
        return accounts;
    }

    public static List<Account> createAccounts(Integer amount) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < amount; i++) {
            accounts.add(new Account(
                Name = generateRandomString(12)
            ));
        }
        return accounts;
    }

    public static List<Order> insertOrders(Integer amount, Id accountId, Id pricebookId) {
        List<Order> orders = createOrders(amount, accountId, pricebookId);
        insert orders;
        return orders;
    }

    public static List<Order> createOrders(Integer amount, Id accountId, Id pricebookId) {
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < amount; i++) {
            orders.add(new Order(
                Name = generateRandomString(12),
                AccountId = accountId,
                Pricebook2Id = pricebookId,
                Status = ORDER_DEFAULT_STATUS,
                EffectiveDate = System.today()
            ));
        }
        return orders;
    }

    public static List<OrderItem> insertOrderItems(Integer amount, Id orderId, PricebookEntry entry) {
        List<OrderItem> orderItems = createOrderItems(amount, orderId, entry);
        insert orderItems;
        return orderItems;
    }

    public static List<OrderItem> createOrderItems(Integer amount, Id orderId, PricebookEntry entry) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Integer i = 0; i < amount; i++) {
            orderItems.add(new OrderItem(
                OrderId = orderId,
                Product2Id = entry.Product2Id,
                PricebookEntryId = entry.Id,
                UnitPrice = TEST_PRICE,
                Quantity = TEST_QUANTITY
            ));
        }
        return orderItems;
    }

    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

}
