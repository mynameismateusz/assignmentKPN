@IsTest
private class OrderSelector_Test {

    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.insertAccounts(1)[0];
        Pricebook2 pricebook = TestDataFactory.getStandardPricebook();
        List<Order> orders = TestDataFactory.insertOrders(10, acc.Id, pricebook.Id);
    }

    @IsTest
    static void getOrdersByIds_POS() {
        //GIVEN
        final Set<Id> ORDER_IDS = new Map<Id, Order>([SELECT Id FROM Order]).keySet();

        //WHEN
        Test.startTest();
        final List<Order> ORDERS = OrderSelector.getOrdersByIds(ORDER_IDS);
        Test.stopTest();

        System.assertEquals(ORDER_IDS.size(), ORDERS.size(), 'Amount of returned Orders should match');
    }

    @IsTest
    static void getOrdersByIds_NEG() {
        //GIVEN
        final Set<Id> EMPTY_SET = new Set<Id>();

        //WHEN
        Test.startTest();
        final List<Order> ORDERS = OrderSelector.getOrdersByIds(EMPTY_SET);
        Test.stopTest();

        System.assertEquals(true, ORDERS.isEmpty(), 'Returned list should be empty');
    }
}
