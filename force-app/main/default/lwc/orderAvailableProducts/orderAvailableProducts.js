import { api, LightningElement, track, wire } from 'lwc';
import { sort } from 'c/utils';
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';


const COLUMNS = [
    { label: 'Name', fieldName: 'Name', sortable: true },
    {
        label: 'List Price',
        fieldName: 'UnitPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    }
];

export default class OrderAvailableProducts extends LightningElement {
    @api recordId;
    @track availableProducts;
    @wire(getAvailableProducts, { orderId: '$recordId' })
    wiredAvailableProducts
    ({error,data}) {
        if (data) {
            this.availableProducts = data;
        } else if (error) {
            console.log(error)
        }
    }
    columns = COLUMNS;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    onHandleSort(event) {
        const res = sort(event, this.products);
        this.products = res.data;
        this.sortDirection = res.sortDirection;
        this.sortedBy = res.sortedBy;
    }
}