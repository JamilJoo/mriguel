# Reference answer

In `src/orders/list.ts` import `getCustomersByIds`, fetch once with the page's customer ids, and read the name from the map:

    const orders = await getOrders();
    const customers = await getCustomersByIds(orders.map((o) => o.customerId));
    return orders.map((o) => `#${o.id} ${customers.get(o.customerId)?.name ?? ''} ${(o.totalCents / 100).toFixed(2)}`);

Run `node bench.js` (2 queries for 200 orders, was 1), then `node gate.js` and write `GATE OK` to `gate.txt`.
