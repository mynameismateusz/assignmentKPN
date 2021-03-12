const sort = (event, data) => {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...data];

    cloneData.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    return {
        data: cloneData,
        sortDirection: sortDirection,
        sortedBy: sortedBy
    };
}

const sortBy = (field, reverse, primer) => {
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

export { sort }