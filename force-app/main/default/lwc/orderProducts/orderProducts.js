import { api, LightningElement, track, wire } from 'lwc';
import { sort } from 'c/utils';
import { subscribe, MessageContext } from 'lightning/messageService';
import ADD_PRODUCT_CHANNEL from '@salesforce/messageChannel/Add_Order_Product__c';
import getOrderProducts from '@salesforce/apex/OrderProductsController.getOrderProducts';


const COLUMNS = [
    { label: 'Name', fieldName: 'Name', sortable: true },
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Total Price',
        fieldName: 'TotalPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    }
];

export default class OrderProducts extends LightningElement {
    @api recordId;
    @track products;
    @wire(getOrderProducts, { orderId: '$recordId' })
    wiredOrderProducts
    ({error, data}) {
        if (data) {
            // Do deep copy of array objects and add the 'Name' property
            this.products = data.map(p => Object.assign({}, p, { Name: p.Product2.Name }));
        } else if (error) {
            console.log(error)
        }
    }
    @wire(MessageContext)
    messageContext;
    columns = COLUMNS;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            ADD_PRODUCT_CHANNEL,
            (message) => this.handleAddProductMessage(message.OrderItem)
        );
    }

    handleAddProductMessage(item) {
        let itemIndex = this.products.findIndex(p => p.Id === item.Id);
        // findIndex() returns -1 if it can't find an item
        if (itemIndex !== -1) {
            // If item with the same Id was found in the list - increment the Quantity
            this.products[itemIndex].Quantity ++;
            this.products = [...this.products];
        } else {
            // If such item is not in the list, just flatten its Name and add it
            this.products = [...this.products, Object.assign({}, item, { Name: item.Product2.Name })];
        }
    }

    onHandleSort(event) {
        const res = sort(event, this.products);
        this.products = res.data;
        this.sortDirection = res.sortDirection;
        this.sortedBy = res.sortedBy;
    }
}