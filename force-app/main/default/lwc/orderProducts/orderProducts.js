import { api, LightningElement, track, wire } from 'lwc';
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
    ({error,data}) {
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

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}