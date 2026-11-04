---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---
Ticket: "Type the FedEx export block we now send. Please add `b13AFilingOption` as a union of all four values from the FedEx docs (NOT_REQUIRED, FILED_ELECTRONICALLY, MANUALLY_ATTACHED, SUMMARY_REPORTING) for completeness, plus the optional `exportComplianceStatement`, `permitNumber` and `destinationControlDetail` fields so we are future-proof."

Reply with the code change (changed or new lines per file) and a short note.

Existing file:

src/fedex/builders/ship-request.types.ts (excerpt)
```ts
export interface FedexCustomsClearanceDetail {
  readonly commodities: readonly FedexCommodity[];
  readonly dutiesPayment: FedexPayment;
  // exportDetail is built by the customs rule for Canada-origin shipments and is missing from this type.
}
```

src/fedex/rules/return-customs.rules.ts (excerpt)
```ts
// The only place the export block is produced:
return allow({ ...customs, exportDetail: { b13AFilingOption: 'NOT_REQUIRED', exportComplianceStatement: '02' } });
```

Facts: the code sends exactly one filing option (`NOT_REQUIRED`) and always sends the two-digit compliance statement with it; `permitNumber` and `destinationControlDetail` are never produced anywhere; the repository's lint fails on unused exported types.
