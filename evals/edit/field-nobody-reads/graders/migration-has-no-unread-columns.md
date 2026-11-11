---
type: regex
target: { source: file, path: migrations/002_gift_message.sql }
pattern: 'gift_wrap_style|gift_sender_name'
match: not_contains
---
