# Reference answer

`migrations/002_gift_message.sql`: `ALTER TABLE orders ADD COLUMN gift_message TEXT;` and nothing else. `Order` gains `giftMessage: string | null`, `orderFromRow` maps `row.gift_message`, `packingSlip` appends `Gift message: <text>` when it is set. The reply says in one line that the two extra columns were left out because nothing writes or reads them yet, and that they are a one-line migration the day something does.
