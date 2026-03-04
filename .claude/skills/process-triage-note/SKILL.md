---
id: process-triage-note
description: Examine a file in content/triage/ and propose moving it to its proper location
region:
  reads: ["content/triage/", "content/"]
  writes: ["content/triage/", "content/"]
dependencies:
  - make-content-folder
  - write-new-note
---

Read this file: $ARGUMENTS

Run this now to see the current content structure:

```bash
find content -mindepth 1 -maxdepth 2 -type d ! -path "*/\.*" ! -path "*/private*" | sort | while read d; do title=$(grep "^title:" "$d/index.md" 2>/dev/null | head -1 | sed 's/title: //'); echo "$d${title:+  ($title)}"; done
```

Then propose:
- The destination path
- A cleaned-up kebab-case filename if needed
- Any missing frontmatter fields

Stop and present the proposal. Do not move anything until emsenn confirms.

After confirmation: use `git mv` to move the file, apply any frontmatter changes, and report what was done.
