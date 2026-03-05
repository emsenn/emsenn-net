---
id: restructure-discipline
description: Move, rename, or reorganize a discipline module while preserving internal links and structure
version: [1, 0]
kind: operational
runtime: inference
triggers:
  - "restructure"
  - "reorganize discipline"
  - "move discipline"
inputs:
  discipline: string
  plan: string?
outputs:
  moves: object[]
  links_fixed: number
region:
  reads: ["content/"]
  writes: ["content/"]
dependencies:
  - audit-vault-references
  - make-content-folder
scopes: []
---

Restructure a discipline: $ARGUMENTS

## Instructions

1. **Survey the current state.** List all files and subdirectories in the discipline
   being restructured:

```bash
find content/[discipline] -type f -name "*.md" | sort
find content/[discipline] -type d | sort
```

2. **Identify all incoming references.** Search the vault for links pointing to the
   discipline:

```bash
grep -r "content/[discipline]" content/ --include="*.md" -l
grep -r "\[\[.*[discipline]" content/ --include="*.md" -l
```

3. **Propose the restructuring.** Present to emsenn:
   - What moves, what stays, what gets created
   - A table of source → destination for every file/directory
   - What incoming links will break and how to fix them
   - What new `index.md` files need to be created (use `/make-content-folder`)

4. **Wait for confirmation.** Do not proceed without explicit approval.

5. **Execute the restructuring** in this order:
   a. Create destination directories with `index.md` files first (use `/make-content-folder`)
   b. Move files with `git mv` to preserve history
   c. Update `index.md` files in affected directories
   d. Fix incoming links in other files
   e. Check for any SKILL.md files that reference moved paths and update them
   f. Run `/audit-content-folders` to verify no directories are missing `index.md`

6. **Report what was done.** List every move, every link fix, and any remaining issues.
