---
description: Create a new note with correct frontmatter in the appropriate content directory
---

Create a new note for: $ARGUMENTS

Run this now to see the current content structure, then pick the right destination:

```bash
find content -mindepth 1 -maxdepth 2 -type d ! -path "*/\.*" ! -path "*/private*" | sort | while read d; do title=$(grep "^title:" "$d/index.md" 2>/dev/null | head -1 | sed 's/title: //'); echo "$d${title:+  ($title)}"; done
```

Then:
1. Choose the destination directory based on the note subject.
2. Derive a kebab-case filename. For babbles, match the date-time format of existing files.
3. Write the file with at minimum `title` and `date-created` (current ISO 8601) frontmatter. No plugin-managed fields.
4. Add a `# Title` heading and leave the body empty.
5. Report the full path created.
