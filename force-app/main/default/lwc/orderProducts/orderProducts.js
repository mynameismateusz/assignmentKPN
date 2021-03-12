import { api, LightningElement, track, wire } from 'lwc';
import { sort } from 'c/utils';
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