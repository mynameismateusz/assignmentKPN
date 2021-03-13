@IsTest
private class OrderProductsController_Test {

    @TestSetup
    static void makeData() {
        Pricebook2 pricebook = TestDataFactory.getStandardPricebook();
        Map<Id, Product2> products = new Map<Id, Product2>(TestDataFactory.insertProducts(10));
        List<PricebookEntry> entries = TestDataFactory.insertPricebookEntries(products.keySet(), pricebook.Id);
        Account acc = TestDataFactory.insertAccounts(1)[0];
        Order o = TestDataFactory.insertOrders(1, acc.Id, pricebook.Id)[0];
    }

    @IsTest
    static void getOrderProducts_POS() {
        //GIVEN
        Order o = [SELECT Id, Pricebook2Id FROM Order LIMIT 1];
        PricebookEntry entry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        final Integer ITEMS_AMOUNT = 5;
        TestDataFactory.insertOrderItems(ITEMS_AMOUNT, o.Id, entry);

        //WHEN
        Test.startTest();
        List<OrderItem> orderItems = OrderProductsController.getOrderProducts(o.Id);
        Test.stopTest();

        //THEN
        System.assertEquals(orderItems.size(), ITEMS_AMOUNT, 'Amount of returned Order products should match');
    }

    @IsTest
    static void getOrderProducts_NEG() {
        //GIVEN
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Order o = TestDataFactory.insertOrders(1, acc.Id, null)[0];

        //WHEN
        Test.startTest();
        List<OrderItem> orderItems = OrderProductsController.getOrderProducts(o.Id);
        Test.stopTest();

        //THEN
        System.assertEquals(true, orderItems.isEmpty(), 'No Order Items should be returned');
    }
}