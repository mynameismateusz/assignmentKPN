import { LightningElement } from 'lwc';
import { sort } from 'c/utils';

const TEST_DATA = [
    { id: 1, Name: 'Prod1', UnitPrice: 10 },
    { id: 2, Name: 'Prod2', UnitPrice: 20 },
    { id: 3, Name: 'Prod3', UnitPrice: 30 }
];

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
    data = TEST_DATA;
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