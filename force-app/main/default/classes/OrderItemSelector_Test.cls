@IsTest
private class OrderItemSelector_Test {

    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.insertAccounts(1)[0];
        Pricebook2 pricebook = TestDataFactory.getStandardPricebook();
        Product2 product = TestDataFactory.insertProducts(1)[0];
        PricebookEntry entry = TestDataFactory.insertPricebookEntries(new Set<Id>{product.Id}, pricebook.Id)[0];
        Order order = TestDataFactory.insertOrders(1, acc.Id, pricebook.Id)[0];
        List<OrderItem> orderItems = TestDataFactory.insertOrderItems(10, order.Id, entry);
    }

    @IsTest
    static void getOrderItemsByOrderId_POS() {
        //GIVEN
        final Order RELATED_ORDER = [SELECT Id, (SELECT Id FROM OrderItems) FROM Order LIMIT 1];

        //WHEN
        Test.startTest();
        final List<OrderItem> ORDER_ITEMS = OrderItemSelector.getOrderItemsByOrderId(RELATED_ORDER.Id);
        Test.stopTest();

        System.assertEquals(ORDER_ITEMS.size(), RELATED_ORDER.OrderItems.size(), 'Amount of returned Order Items should match');
    }

    @IsTest
    static void getOrderItemsByOrderId_NEG() {
        //GIVEN
        final Account ACC = [SELECT Id FROM Account LIMIT 1];
        final Pricebook2 PRICEBOOK = [SELECT Id FROM Pricebook2 LIMIT 1];
        final Order NEW_ORDER = TestDataFactory.insertOrders(1, ACC.Id, PRICEBOOK.Id)[0];

        //WHEN
        Test.startTest();
        final List<OrderItem> ORDER_ITEMS = OrderItemSelector.getOrderItemsByOrderId(NEW_ORDER.Id);
        Test.stopTest();

        System.assertEquals(true, ORDER_ITEMS.isEmpty(), 'Returned list should be empty');
    }

    @IsTest
    static void getOrderItemsByOrderAndProductId_POS() {
        //GIVEN
        final Order RELATED_ORDER = [SELECT Id, (SELECT Id FROM OrderItems) FROM Order LIMIT 1];
        final Product2 PRODUCT = [SELECT Id FROM PRODUCT2 LIMIT 1];

        //WHEN
        Test.startTest();
        final List<OrderItem> ORDER_ITEMS = OrderItemSelector.getOrderItemsByOrderAndProductId(RELATED_ORDER.Id, PRODUCT.Id);
        Test.stopTest();

        System.assertEquals(ORDER_ITEMS.size(), RELATED_ORDER.OrderItems.size(), 'Amount of returned Order Items should match');
    }

    @IsTest
    static void getOrderItemsByOrderAndProductId_NEG() {
        //GIVEN
        final Account ACC = [SELECT Id FROM Account LIMIT 1];
        final Pricebook2 PRICEBOOK = [SELECT Id FROM Pricebook2 LIMIT 1];
        final Order NEW_ORDER = TestDataFactory.insertOrders(1, ACC.Id, PRICEBOOK.Id)[0];
        final Product2 PRODUCT = [SELECT Id FROM PRODUCT2 LIMIT 1];

        //WHEN
        Test.startTest();
        final List<OrderItem> ORDER_ITEMS = OrderItemSelector.getOrderItemsByOrderAndProductId(NEW_ORDER.Id, PRODUCT.Id);
        Test.stopTest();

        System.assertEquals(true, ORDER_ITEMS.isEmpty(), 'Returned list should be empty');
    }
}