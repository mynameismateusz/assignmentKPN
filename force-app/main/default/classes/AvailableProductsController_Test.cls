@IsTest
private class AvailableProductsController_Test {

    @TestSetup
    static void makeData() {
        Pricebook2 pricebook = TestDataFactory.getStandardPricebook();
        Map<Id, Product2> products = new Map<Id, Product2>(TestDataFactory.insertProducts(10));
        List<PricebookEntry> entries = TestDataFactory.insertPricebookEntries(products.keySet(), pricebook.Id);
        Account acc = TestDataFactory.insertAccounts(1)[0];
        Order o = TestDataFactory.insertOrders(1, acc.Id, pricebook.Id)[0];
    }

    @IsTest
    static void getAvailableProducts_POS() {
        //GIVEN
        Order o = [SELECT Id, Pricebook2Id FROM Order LIMIT 1];

        //WHEN
        Test.startTest();
        List<PricebookEntry> available = AvailableProductsController.getAvailableProducts(o.Id);
        Test.stopTest();

        //THEN
        List<PricebookEntry> entries = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id =: o.Pricebook2Id
            AND IsActive = TRUE
        ];

        System.assertEquals(entries.size(), available.size(), 'Amount of returned available products should match');
    }

    @IsTest
    static void getAvailableProducts_NEG() {
        //GIVEN
        Account acc = [SELECT Id FROM Account LIMIT 1];
        // Order's Pricebook Id is empty
        Order o = TestDataFactory.insertOrders(1, acc.Id, null)[0];

        //WHEN
        Test.startTest();
        List<PricebookEntry> available = AvailableProductsController.getAvailableProducts(o.Id);
        Test.stopTest();

        //THEN
        System.assertEquals(true, available.isEmpty(), 'No available products should be found');
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
        List<OrderItem> orderItems = AvailableProductsController.getOrderProducts(o.Id);
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
        List<OrderItem> orderItems = AvailableProductsController.getOrderProducts(o.Id);
        Test.stopTest();

        //THEN
        System.assertEquals(true, orderItems.isEmpty(), 'No Order Items should be returned');
    }

    @IsTest
    static void addOrderItem_Insert_POS() {
        //GIVEN
        Order o = [SELECT Id, Pricebook2Id FROM Order LIMIT 1];
        Product2 product = TestDataFactory.insertProducts(1)[0];
        PricebookEntry entry = TestDataFactory.insertPricebookEntries(new Set<Id>{product.Id}, o.Pricebook2Id)[0];
        OrderItem oi = TestDataFactory.createOrderItems(1, o.Id, entry)[0];
        Map<String, Object> deserializedItem = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(oi));

        //WHEN
        Test.startTest();
        OrderItem insertedItem = AvailableProductsController.addOrderItem(o.Id, deserializedItem);
        Test.stopTest();

        //THEN
        System.assertEquals(o.Id, insertedItem.OrderId, 'Order Id be set correctly');
        System.assertEquals(oi.Quantity, insertedItem.Quantity, 'Quantity be set correctly');
        System.assertEquals(oi.PricebookEntryId, insertedItem.PricebookEntryId, 'PricebookEntryId be set correctly');
        System.assertEquals(oi.UnitPrice, insertedItem.UnitPrice, 'UnitPrice be set correctly');
        System.assertEquals(oi.Product2Id, insertedItem.Product2Id, 'Product2Id be set correctly');
    }

    @IsTest
    static void addOrderItem_Upsert_POS() {
        //GIVEN
        final Integer QUANTITY_TO_ADD = 10;
        Order o = [SELECT Id, Pricebook2Id FROM Order LIMIT 1];
        PricebookEntry entry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        OrderItem oi = TestDataFactory.createOrderItems(1, o.Id, entry)[0];
        oi.Quantity = QUANTITY_TO_ADD;
        insert oi;
        Map<String, Object> deserializedItem = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(oi));

        //WHEN
        Test.startTest();
        OrderItem insertedItem = AvailableProductsController.addOrderItem(o.Id, deserializedItem);
        Test.stopTest();

        //THEN
        System.assertEquals(o.Id, insertedItem.OrderId, 'Order Id be set correctly');
        System.assertEquals(oi.Quantity + QUANTITY_TO_ADD, insertedItem.Quantity, 'Quantity be set correctly');
    }
}