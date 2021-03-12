import { api, LightningElement, track, wire } from 'lwc';
import { sort } from 'c/utils';
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';
import getOrderProducts from '@salesforce/apex/AvailableProductsController.getOrderProducts';
import insertOrderItem from '@salesforce/apex/AvailableProductsController.insertOrderItem';

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
            .then((orderProds) => {
                // Sorting available Products. If product was already added to the Order, it goes to the beginning of a list.
                this.availableProducts = availableProducts.sort((toSort) => orderProds.some(p => p.Product2Id === toSort.Product2Id) ? -1 : 1);
            })
            .catch((error) => {
                console.log(error);
            });
        } else if (error) {
            console.log(error)
        }
    }
    columns = COLUMNS;
    showSpinner = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    onHandleSort(event) {
        const res = sort(event, this.availableProducts);
        this.products = res.data;
        this.sortDirection = res.sortDirection;
        this.sortedBy = res.sortedBy;
    }

    handleRowAction(event) {
        this.showSpinner = true;
        if (event.detail.action.name === ADD_BUTTON_NAME) {
            this.upsertOrderItem(this.createOrderItem(event.detail.row, this.recordId));
        }
    }

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

    upsertOrderItem(orderItem) {
        console.log(orderItem);
        insertOrderItem({ orderId: this.recordId, jsonOrderItem: orderItem})
            .then(result => {
                console.log(result);
            })
            .catch(error => {
                console.log(error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }
}