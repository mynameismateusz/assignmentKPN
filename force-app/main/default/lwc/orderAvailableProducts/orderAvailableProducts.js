import { api, LightningElement, track, wire } from 'lwc';
import { sort, toastSuccess, toastWarning } from 'c/utils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import ADD_PRODUCT_CHANNEL from '@salesforce/messageChannel/Add_Order_Product__c';
import ACTIVATE_ORDER_CHANNEL from '@salesforce/messageChannel/Activate_Order__c';
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';
import getOrderProducts from '@salesforce/apex/AvailableProductsController.getOrderProducts';
import addOrderItem from '@salesforce/apex/AvailableProductsController.addOrderItem';
import ORDER_STATUS from '@salesforce/schema/Order.Status';
import ProductAdded from '@salesforce/label/c.ProductAdded';
import ProductNotAddedErr from '@salesforce/label/c.ProductNotAddedErr';
import ContactAdminErr from '@salesforce/label/c.ContactAdminErr';

const ADD_BUTTON_NAME = 'add_button';
const COLUMNS = [
    { label: 'Name', fieldName: 'Name', sortable: true },
    {
        label: 'List Price',
        fieldName: 'UnitPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        type: 'button',
        initialWidth: 75,
        typeAttributes: {
            label: 'Add',
            title: 'Add',
            variant: 'brand',
            name: ADD_BUTTON_NAME
        }
    }
];

export default class OrderAvailableProducts extends LightningElement {
    @api recordId;
    @track availableProducts;
    @wire(getAvailableProducts, { orderId: '$recordId' })
    wiredAvailableProducts
    ({error, data}) {
        if (data) {
            const availableProducts = [...data];
            getOrderProducts({ orderId: this.recordId })
            .then((orderProducts) => {
                // Sorting available Products. If product was already added to the Order, it goes to the beginning of a list.
                this.availableProducts = availableProducts.sort((a) => (orderProducts.some(p => p.Product2Id == a.Product2Id) ? -1 : 1));
            })
            .catch((error) => {
                console.log(error);
            });
        } else if (error) {
            console.log(error)
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: [], optionalFields: [ORDER_STATUS] })
    order
    ({error, data}) {
        if (data) {
            // If order is Active => disable Add Product buttons
            this.updateAddButtons(this.isActivated(data));
        } else if (error) {
            console.log(error);
        }
    }
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

    isActivated(order) {
        return getFieldValue(order, ORDER_STATUS) === 'Activated' ? true : false;
    }

    /**
     * Subscribe to the Activate Order to receive events
     */
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            ACTIVATE_ORDER_CHANNEL,
            (message) => this.handleActivateOrderMsg(message.orderId)
        );
    }

    /**
     * Verify orderId and disable 'Add' buttons
     * @param {String} orderId
     */
    handleActivateOrderMsg(orderId) {
        if (this.recordId === orderId) {
            this.updateAddButtons(true);
        }
    }

    /**
     * Disable or Enable 'Add' buttons when Order is activated/deactivated
     * It's done by columns search in case the columns order is changed in the future
     */
     updateAddButtons(disable) {
        this.columns.find(c => c.type === 'button' && c.typeAttributes.name === ADD_BUTTON_NAME).typeAttributes.disabled = disable;
        this.columns = [...this.columns];
    }

    onHandleSort(event) {
        const res = sort(event, this.availableProducts);
        this.availableProducts = res.data;
        this.sortDirection = res.sortDirection;
        this.sortedBy = res.sortedBy;
    }

    handleRowAction(event) {
        this.showSpinner = true;
        if (event.detail.action.name === ADD_BUTTON_NAME) {
            this.handleAddProduct(event.detail.row);
        }
    }

    /**
     * Add Product to the Order via Apex and publish event with the results
     * @param {any} pricebookEntry Selected by clicking the 'Add' button
     */
    handleAddProduct(pricebookEntry) {
        const orderItem = this.createOrderItem(pricebookEntry, this.recordId);
        addOrderItem({ orderId: this.recordId, jsonOrderItem: orderItem})
            .then(result => {
                toastSuccess(this, `${ProductAdded}`);
                // Send message with newly added Order Product
                publish(this.messageContext, ADD_PRODUCT_CHANNEL, { OrderItem: result });
            })
            .catch(error => {
                toastWarning(this, `${ProductNotAddedErr} ${ContactAdminErr} ${error.body.message}`);
                console.log(error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    /**
     * Create new Order Item record to upsert via Apex
     * @param {any} pricebookEntry
     * @param {String} orderId Id of the current Order
     * @returns OrderItem ready to be send to Apex
     */
    createOrderItem(pricebookEntry, orderId) {
        let orderItem = {
            Product2Id: pricebookEntry.Product2Id,
            OrderId: orderId,
            UnitPrice: pricebookEntry.UnitPrice,
            ListPrice: pricebookEntry.UnitPrice,
            TotalPrice: pricebookEntry.UnitPrice,
            PricebookEntryId: pricebookEntry.Id,
            Quantity: 1,
            Product2: {
                Name: pricebookEntry.Name,
                Id: pricebookEntry.Product2Id
            }
        };
        return orderItem;
    }
}