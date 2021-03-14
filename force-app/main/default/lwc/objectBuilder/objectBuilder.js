/**
 * Create representation of Salesforce OrderItem using PricebookEntry.
 * Can be used to insert record via Apex.
 * @param {PricebookEntry} pricebookEntry
 * @param {String} orderId
 * @param {Integer} quantity
 * @returns OrderItem ready to be sent to Apex
 */
const createOrderItem = (pricebookEntry, orderId, quantity)  => {
    let orderItem = {
        Product2Id: pricebookEntry.Product2Id,
        OrderId: orderId,
        UnitPrice: pricebookEntry.UnitPrice,
        ListPrice: pricebookEntry.UnitPrice,
        TotalPrice: pricebookEntry.UnitPrice,
        PricebookEntryId: pricebookEntry.Id,
        Quantity: quantity,
        Product2: {
            Name: pricebookEntry.Name,
            Id: pricebookEntry.Product2Id
        }
    };
    return orderItem;
}

export { createOrderItem }