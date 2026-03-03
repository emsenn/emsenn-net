---
description: Scan the vault for broken internal references (wikilinks and markdown links) and report them categorized by type
---

Run the reference audit script and present the results:

```bash
python scripts/audit-vault-references.py --vault-root content --category --format table
```

If the output is large, also generate a JSON report for further processing:

```bash
python scripts/audit-vault-references.py --vault-root content --category --format json --output slop/reference-audit.json
```

Then:
1. Summarize the results: total broken references, top categories, top source files.
2. For each category, propose a remediation strategy:
   - **person**: create a stub page in `encyclopedia/people/` or fix the link target
   - **term**: create a stub in the appropriate `terms/` directory or fix the link
   - **concept**: create a stub in the appropriate `concepts/` directory or fix the link
   - **path**: the link uses a relative path that does not resolve — check if the target was moved or renamed
   - **unknown**: inspect manually
3. Present the proposal to emsenn. Do not create or delete files without confirmation.

$ARGUMENTS
