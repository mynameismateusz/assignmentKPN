import { api, LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { sort, toastSuccess, toastWarning } from 'c/utils';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import ADD_PRODUCT_CHANNEL from '@salesforce/messageChannel/Add_Order_Product__c';
import ACTIVATE_ORDER_CHANNEL from '@salesforce/messageChannel/Activate_Order__c';
import getOrderProducts from '@salesforce/apex/OrderProductsController.getOrderProducts';
import activateOrder from '@salesforce/apex/OrderProductsController.activateOrder';
import ORDER_STATUS from '@salesforce/schema/Order.Status';
import ContactAdminErr from '@salesforce/label/c.ContactAdminErr';
import OrderActivated from '@salesforce/label/c.OrderActivated';
import OrderNotActivatedErr from '@salesforce/label/c.OrderNotActivatedErr';

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
    @wire(getRecord, { recordId: '$recordId', fields: [], optionalFields: [ORDER_STATUS] })
    order;
    @wire(MessageContext)
    messageContext;
    columns = COLUMNS;
    showSpinner = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    get isActivated() {
        const orderStatus = getFieldValue(this.order.data, ORDER_STATUS);
        return orderStatus === 'Activated' ? true : false;
    }

    /**
     * Used to refresh the wired Order record.
     * Since no other fields than Id are provided, no actual change is done in the DB
     */
    updateRecordView() {
        updateRecord({fields: { Id: this.recordId }});
    }

    /**
     * Subscribe to the Add Product to receive events
     */
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            ADD_PRODUCT_CHANNEL,
            (message) => this.handleAddProductMsg(message.OrderItem)
        );
    }

    /**
     * Handle message and add new Product to the list
     * Increases Quantity if Product was already added to the Order, otherwise adds a new entry
     * @param {any} newItem New Order Item
     */
    handleAddProductMsg(newItem) {
        let existingItem = this.products.find(p => p.Id === newItem.Id);
        if (existingItem) {
            // If item with the same Id was found in the list - update the Quantity
            existingItem.Quantity = newItem.Quantity;
            this.products = [...this.products];
        } else {
            // If such item is not in the list, just flatten its Name and add it
            this.products = [...this.products, Object.assign({}, newItem, { Name: newItem.Product2.Name })];
        }
    }

    handleActivate() {
        this.showSpinner = true;
        activateOrder({ orderId: this.recordId })
            .then(result => {
                toastSuccess(this, `${OrderActivated}`);
                publish(this.messageContext, ACTIVATE_ORDER_CHANNEL, { orderId: this.recordId });
                this.updateRecordView();
            })
            .catch(error => {
                console.log(error);
                toastWarning(this, `${OrderNotActivatedErr} ${ContactAdminErr} ${JSON.stringify(error, null, 2)}`);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    onHandleSort(event) {
        const res = sort(event, this.products);
        this.products = res.data;
        this.sortDirection = res.sortDirection;
        this.sortedBy = res.sortedBy;
    }
}