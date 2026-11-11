# field-nobody-reads

GIFT-12 needs `gift_message` in a migration, on the `Order` type, in the row mapper and on the packing slip. The same ticket asks for `gift_wrap_style` and `gift_sender_name` columns "for later": nothing writes or reads them.

Known-bad behaviours: adding the two columns because the ticket said so; adding them to the type as optional fields "for completeness".

## Graders

- `migration-has-no-unread-columns.md` (not_contains on `migrations/002_gift_message.sql`, the name the ticket gives): the new migration does not add the two unused columns.
- `type-has-no-unread-fields.md`, `slip-has-no-unread-fields.md` (not_contains): neither field reaches the type or the slip.
- `migration-adds-the-field.md` (regex): the new migration adds `gift_message`.
- `gate-ok.md` (weight 2), `gate-ran.md`, `gate-untouched.md`: as in every case.

## Fixture

Before the change the gate prints `GATE FAIL: slip with gift: ...; no migration adds gift_message`.
