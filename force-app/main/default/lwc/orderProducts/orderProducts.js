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

    /** Fetch OrderItems from Apex to display them in the datatable */
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
    /** Order record is queried to verify its Status and steer 'Activate' button availability */
    @wire(getRecord, { recordId: '$recordId', fields: [], optionalFields: [ORDER_STATUS] })
    order;

    /** Verifies Order status. 'Activate' button is disabled if Order is already Active */
    get isActivated() {
        return getFieldValue(this.order.data, ORDER_STATUS) === 'Activated' ? true : false;
    }

    /** Returns amount of Order Products */
    get productsAmountLabel() {
        return this.products ? `(${this.products.length})` : '';
    }

    get hasProducts() {
        return this.products?.length > 0;
    }

    /**
     * Used to refresh the wired Order record.
     * Since no other fields than Id are provided, no actual change is done in the DB
     */
    updateRecordView = () => updateRecord({fields: { Id: this.recordId }});

    /** Subscribe to the Add Product to receive events */
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
     * @param {OrderItem} newItem New Order Item
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

    /** Activate Order on 'Activate' button click */
    handleActivate() {
        this.showSpinner = true;
        activateOrder({ orderId: this.recordId })
            .then(result => this.handleOrderActivationSuccess(result))
            .catch(error => (this.handleOrderActivationFail(error)))
            .finally(() => this.showSpinner = false)
    }

    /**
     * Send message with Id of activated Order and refresh the wired record
     * @param {Order} order
     */
    handleOrderActivationSuccess(order) {
        toastSuccess(this, `${OrderActivated}`);
        // Send message with newly activated Order Id
        publish(this.messageContext, ACTIVATE_ORDER_CHANNEL, { orderId: order.Id });
        // Update wired Order to refresh the Status
        this.updateRecordView();
    }

    /**
     * Display toast with error message.
     * Displays message from Apex if possible.
     * @param {any} err
     */
    handleOrderActivationFail(err) {
        const errMsg = err.body.message ? err.body.message : err;
        toastWarning(this, `${OrderNotActivatedErr} ${ContactAdminErr} ${errMsg}`);
    }

    /**
     * Sort columns on table header click
     * @param {any} event
     */
    onHandleSort(event) {
        const res = sort(event, this.products);
        this.products = res.data;
        this.sortDirection = res.sortDirection;
        this.sortedBy = res.sortedBy;
    }
}