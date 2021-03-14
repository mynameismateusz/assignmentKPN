import { api, LightningElement, track, wire } from 'lwc';
import { sort, toastSuccess, toastWarning } from 'c/utils';
import { createOrderItem } from 'c/objectBuilder';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import ADD_PRODUCT_CHANNEL from '@salesforce/messageChannel/Add_Order_Product__c';
import ACTIVATE_ORDER_CHANNEL from '@salesforce/messageChannel/Activate_Order__c';
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';
import getOrderProducts from '@salesforce/apex/AvailableProductsController.getOrderProducts';
import addOrderItem from '@salesforce/apex/AvailableProductsController.addOrderItem';
import getOrderAvailableProductsCount from '@salesforce/apex/AvailableProductsController.getOrderAvailableProductsCount';
import ORDER_STATUS from '@salesforce/schema/Order.Status';
import ProductAdded from '@salesforce/label/c.ProductAdded';
import ProductNotAddedErr from '@salesforce/label/c.ProductNotAddedErr';
import ContactAdminErr from '@salesforce/label/c.ContactAdminErr';

const ADD_BUTTON_NAME = 'add_button';
const DEFAULT_QUANTITY = 1;
const INITIAL_PRODUCTS_QUERY_SIZE = 15;

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
    @api totalNumberOfRows;
    @track availableProducts;
    @wire(MessageContext)
    messageContext;
    columns = COLUMNS;
    showSpinner = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    /** Used to avoid displaying duplicate items, see skipDuplicateProducts() */
    orderItemProductIds;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    /**
     * Fetch available PricebookEntries to display them in the datatable
     * Products already added to the Order are displayed at the top
     * Amount of all available PricebookEntries is queried to support onscroll loading
     */
    @wire(getAvailableProducts, { orderId: '$recordId', amount: INITIAL_PRODUCTS_QUERY_SIZE, offset: 0 })
    wiredAvailableProducts
    ({error, data}) {
        if (data) {
            getOrderProducts({ orderId: this.recordId })
            .then(orderProducts => this.handleFetchProducts([...data], orderProducts))
            getOrderAvailableProductsCount({ orderId: this.recordId })
            .then((amount) => this.totalNumberOfRows = amount)
            .catch((error) => console.log(error));
        } else if (error) {
            console.log(error)
        }
    }

    /**
     * Add Order Products to the beginning of the list and then the remaining Available Products
     * @param {PricebookEntry[]} availableProducts items available for the Order
     * @param {OrderItem[]} orderProducts products already added to the Order
     */
    handleFetchProducts(availableProducts, orderProducts) {
        // Extract PricebookEntries from Order Products
        const pricebookEntriesOfOrderProducts = orderProducts.map(p => p.PricebookEntry);
        // Get Product2Ids from Order Products to skip duplicates from Available Products
        this.orderItemProductIds = pricebookEntriesOfOrderProducts.map(p => p.Product2.Id);
        // Add Order Products and Available Products to display in the list. Duplicates are skipped.
        this.availableProducts = pricebookEntriesOfOrderProducts.concat(this.skipDuplicateProducts(availableProducts));
    };

    /**
     * On the initial pageload OrderItems are added to the top of the list.
     * It can cause duplicate items to appear when Available Products (Pricebook Entries) are fetched.
     * To prevent that, whenever new Pricebook Entries are queried, we skip those items, by comparing
     * their Product2Ids with those of OrderItems (stored in 'orderItemProductIds' array).
     * @param {PricebookEntry[]} newProducts
     * @returns {PricebookEntry[]} Array without duplicate items
     */
    skipDuplicateProducts = (newProducts) => newProducts.filter(p => !this.orderItemProductIds.includes(p.Product2.Id))

    /** Order record is queried to verify its Status and steer 'Add' buttons availability */
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

    /** Returns amount of Order Products */
    get productsAmountLabel() {
        return this.totalNumberOfRows ? `(${this.totalNumberOfRows})` : '';
    }

    /** Used to steer datatable visibility. Returns true if there is at least one Product to display. */
    get hasProducts() {
        return this.availableProducts ? this.availableProducts.length > 0 : false;
    }

    /** Used to display 'products not found'. Returns true if there is there are no Products to display. */
    get noProductsFound() {
        return this.availableProducts ? this.availableProducts.length === 0 : false;
    }

    /**
     * Fetch more available products and add them to the end of the list.
     * Invoked by scrolling to the bottom of the products list.
     * Offset size is defined in the datatable.
     * Handles displaying and hiding the loading spinner.
     * @param {any} event
     */
    loadMoreProducts(event) {
        const target = event.target;
        //Display a spinner to signal that data is being loaded
        target.isLoading = true;
        getAvailableProducts({ orderId: this.recordId, amount: target.loadMoreOffset, offset: this.availableProducts.length })
        .then((data) => this.handleFetchedProducts(data, target))
        .catch((error) => console.log(error));
    }

    /**
     * Add fetched OrderItems at the end of the list.
     * Disable infinite loading if all items were already queried.
     * @param {OrderItem[]} newProducts OrderItems fetched from Apex
     * @param {lightning-datatable} target Target that invoked loadmore event
     */
    handleFetchedProducts(newProducts, target) {
        //Appends new data to the end of the table
        this.availableProducts = this.availableProducts.concat(this.skipDuplicateProducts(newProducts));
        target.isLoading = false;
        //Disable infinite loading if all of the items were already fetched
        if (this.availableProducts.length >= this.totalNumberOfRows) {
            target.enableInfiniteLoading = false;
        }
    }


    /** Verifies Order status. 'Add' buttons are disabled if Order is Active */
    isActivated = (order) => getFieldValue(order, ORDER_STATUS) === 'Activated' ? true : false;

    /** Subscribe to the Activate Order to receive events */
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

    handleRowAction(event) {
        this.showSpinner = true;
        if (event.detail.action.name === ADD_BUTTON_NAME) {
            this.handleAddProduct(event.detail.row);
        }
    }

    /**
     * Add Product to the Order via Apex and publish event with the results
     * @param {PricebookEntry} pricebookEntry Selected by clicking the 'Add' button
     */
    handleAddProduct(pricebookEntry) {
        const orderItem = createOrderItem(pricebookEntry, this.recordId, DEFAULT_QUANTITY);
        addOrderItem({ orderId: this.recordId, jsonOrderItem: orderItem})
            .then(result => this.handleAddProductSuccess(result))
            .catch(error => this.handleAddProductFail(error))
            .finally(() => this.showSpinner = false);
    }

    /**
     * Send message with new OrderItem and display the toast
     * @param {OrderItem} item Newly added Order Product
     */
    handleAddProductSuccess(item) {
        toastSuccess(this, `${ProductAdded}`);
        // Send message with newly added Order Product
        publish(this.messageContext, ADD_PRODUCT_CHANNEL, { OrderItem: item });
    }

    /**
     * Display toast with error message.
     * Displays message from Apex if possible.
     * @param {any} err
     */
    handleAddProductFail(err) {
        const errMsg = err.body.message ? err.body.message : err;
        toastWarning(this, `${ProductNotAddedErr} ${ContactAdminErr} ${errMsg}`);
    }

    /**
     * Disable or Enable 'Add' buttons when Order is activated/deactivated
     * It's done by columns search in case the columns order is changed in the future
     */
     updateAddButtons(disable) {
        this.columns.find(c => c.type === 'button' && c.typeAttributes.name === ADD_BUTTON_NAME).typeAttributes.disabled = disable;
        this.columns = [...this.columns];
    }

    /**
     * Sort columns on table header click
     * @param {any} event
     */
     onHandleSort(event) {
        const res = sort(event, this.availableProducts);
        this.availableProducts = res.data;
        this.sortDirection = res.sortDirection;
        this.sortedBy = res.sortedBy;
    }
}