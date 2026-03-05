---
description: Scan the vault for broken internal references (wikilinks and markdown links) and report them categorized by type
id: audit-vault-references
version: [0, 1]
kind: operational
runtime: script
triggers:
  - "audit references"
  - "find broken links"
  - "check references"
inputs:
  path: string?
outputs:
  broken_references: object[]
  categories: object
region:
  reads: ["content/"]
  writes: []
dependencies: []
scopes: []
---
Run the reference audit script (colocated in this skill directory) and present the results:

```bash
python .claude/skills/audit-vault-references/audit-vault-references.py --vault-root content --category --format table
```

If the output is large, also generate a JSON report for further processing:

```bash
python .claude/skills/audit-vault-references/audit-vault-references.py --vault-root content --category --format json --output slop/reference-audit.json
```

### Additional scripts in this directory

- `fix-refs.py` — Automated fixer for relative-path reference errors (reads audit output,
  finds correct targets, computes relative paths)
- `fix-paths.py` — Bulk path corrector for common patterns (wrong depth, missing segments,
  encoded paths)
- `fix-files.py` — Targeted file-level reference fixes

Then:
1. Summarize the results: total broken references, top categories, top source files.
2. For each category, propose a remediation strategy:
   - **person**: create a stub page in `general/people/` or fix the link target
   - **term**: create a stub in the appropriate `terms/` directory or fix the link
   - **concept**: create a stub in the appropriate `concepts/` directory or fix the link
   - **path**: the link uses a relative path that does not resolve — check if the target was moved or renamed
   - **unknown**: inspect manually
3. Present the proposal to emsenn. Do not create or delete files without confirmation.

$ARGUMENTS
