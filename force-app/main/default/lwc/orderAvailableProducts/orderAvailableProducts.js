import { api, LightningElement, track, wire } from 'lwc';
import { sort } from 'c/utils';
import getAvailableProducts from '@salesforce/apex/AvailableProductsController.getAvailableProducts';
import getOrderProducts from '@salesforce/apex/AvailableProductsController.getOrderProducts';


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
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    onHandleSort(event) {
        const res = sort(event, this.availableProducts);
        this.products = res.data;
        this.sortDirection = res.sortDirection;
        this.sortedBy = res.sortedBy;
    }
}