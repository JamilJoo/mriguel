---
type: llm
weight: 1
---
PASS only if all of the following hold; otherwise FAIL.

1. The new type carries what the code sends: `b13AFilingOption` typed as the single literal `'NOT_REQUIRED'` (or an equivalent single-value type), and `exportComplianceStatement` as a required string.
2. No union of the four documented values and no `permitNumber` or `destinationControlDetail` fields are added, since nothing produces them.
3. `exportDetail` is added to `FedexCustomsClearanceDetail` as optional (it is absent outside Canada-origin shipments), in the existing types file, with no new file.
4. The response explains, in at least a sentence, why the extra values and fields are left out (nothing sends them; they can be added when something does). Any wording counts.

Do not fail the response for the phrasing of that explanation, for comments, or for anything not listed above.
