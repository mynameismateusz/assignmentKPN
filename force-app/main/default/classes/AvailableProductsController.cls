public with sharing class AvailableProductsController {

    @AuraEnabled(Cacheable=true)
    public static List<PricebookEntry> getAvailableProducts(Id orderId) {
        if (String.isBlank(orderId)) {
            throw new AuraHandledException('Order Id is empty');
        }
        if ( orderId.getSObjectType() != Order.getSObjectType()) {
            throw new AuraHandledException('Provided Id is of an incorrect type');
        }
        try {
            return AvailableProductsService.getAvailableProducts(orderId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
