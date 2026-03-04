---
description: Scan files for frontmatter issues and fix them (wrong field names, missing required fields, formatting problems)
id: fix-frontmatter
region:
  reads: ["content/"]
  writes: ["content/"]
dependencies: []
---

Fix frontmatter issues in: $ARGUMENTS

If `$ARGUMENTS` is empty, scan the entire vault. Otherwise, scope to the given path.

## Instructions

1. **Scan for frontmatter issues.** Check each `.md` file for:

   - **Wrong date field**: `date:` should be `date-created:` (the vault standard).
     Do NOT change files that use `date:` as a different field (e.g., event dates).
   - **Missing required fields**: every file needs at minimum `title:` and `date-created:`.
   - **Malformed YAML**: unclosed quotes, bad indentation, invalid types.
   - **`title:` mismatch**: if `title:` does not match the `# Heading` in the body,
     flag it (but do not auto-fix — titles are authoritative).

   ```bash
   # Find files using `date:` instead of `date-created:`
   grep -rl "^date:" content/ --include="*.md" | head -50
   # Find files missing `title:`
   grep -rL "^title:" content/ --include="*.md" | head -50
   ```

2. **Present findings** organized by issue type and count.

3. **Propose fixes.** For each issue type, state exactly what will change.
   For `date:` → `date-created:` renames, show a sample before/after.

4. **Wait for confirmation.** Do not edit files without explicit approval.

5. **Execute fixes.** For bulk operations, process files in batches and report
   progress. After fixing, re-scan to confirm the issues are resolved.
