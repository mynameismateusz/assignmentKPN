Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
List<PricebookEntry> entries = new List<PricebookEntry>();
for (Product2 p : [SELECT Id FROM Product2]) {
    entries.add(new PricebookEntry(
        Product2Id = p.Id,
        Pricebook2Id = pricebook.Id,
        isActive = true,
        UnitPrice = getRandomNum()
    ));
}
insert entries;

List<Order> orders = [SELECT Id FROM Order];
for (Order o : orders) {
    o.Pricebook2Id = pricebook.Id;
}
update orders;

public Integer getRandomNum() {
    final integer STRING_LENGTH = 4;
    return Math.Round(Math.Random() * ((Math.pow(10,STRING_LENGTH) - 1)-Math.pow(10,STRING_LENGTH -1)) + Math.pow(10,STRING_LENGTH -1));
}
