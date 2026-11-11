# Reference answer

Grep `totalCents`: nine readers. Convert in the seven that assume euros: `(order.totalCents / 100).toFixed(2)` in the invoice, the receipt email and the CSV; `order.totalCents >= FREE_SHIPPING_FROM_EUR * 100`; `Math.floor(order.totalCents / 1000)`; `sum + o.totalCents / 100` in the revenue tile; `order.totalCents > 1000 * 100` in the review rule. Leave the refund (already converts) and the provider payload (minor units on purpose). Run the gate. The reply lists all nine readers: seven changed, two left and why.
