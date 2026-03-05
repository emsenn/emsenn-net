---
description: List all published content directories that are missing an index.md
id: audit-content-folders
version: [0, 1]
kind: operational
runtime: script
triggers:
  - "audit folders"
  - "find missing indexes"
  - "check content structure"
inputs: {}
outputs:
  missing_indexes: string[]
region:
  reads: ["content/"]
  writes: []
dependencies: []
scopes: []
---
Run this command now and report the results:

```bash
find content -mindepth 1 -maxdepth 3 -type d ! -path "*/\.*" ! -path "*/private*" ! -path "*/triage*" ! -path "*/slop*" ! -path "*/meta*" ! -path "*/tags*" ! -path "*/assets*" | sort | while read d; do [ ! -f "$d/index.md" ] && echo "$d"; done
```

Present the list to emsenn and ask which directories to address first.
