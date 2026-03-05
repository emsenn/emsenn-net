---
description: Clean, normalize, and manage tags and type fields across the vault
id: manage-tags
version: [0, 1]
kind: operational
runtime: script
triggers:
  - "manage tags"
  - "fix tags"
  - "clean tags"
  - "normalize tags"
inputs:
  path: string?
outputs:
  files_modified: number
region:
  reads: ["content/"]
  writes: ["content/"]
dependencies: []
scopes: []
---
Manage tags across the vault: $ARGUMENTS

## Tag Architecture

Tags in this vault follow a separation of concerns:

- **`type:` frontmatter field** — encodes content type (term, lesson, index, etc.),
  derived from directory position. Maps to Schema.org `@type`.
- **`tags:` array** — pure cross-cutting thematic discovery surface. Tags signal
  conceptual territory that does not duplicate directory position.

### Tag conventions

- **CamelCase**: capitalize every word including articles and prepositions
  (per WCAG screen reader guidance). Example: `PoliticalTheory`, `SettlerColonialism`.
- **3-5 tags per page** (maximum 10)
- **Most-specific to least-specific** ordering
- **No nesting** — flat tags only (no `/` separators)
- **No discipline echoes** — do not tag a file with its own directory name
  (e.g., no `Sociology` tag on files in `sociology/`)
- Tags are drawn from the controlled vocabulary at `content/tags/`

## Scripts

Two colocated scripts handle tag operations:

### Fix and normalize tags

```bash
python .claude/skills/manage-tags/fix-tags.py
```

Normalizes and cleans tag values across the vault:
- Removes path-like tags (containing `/` or `.md`)
- Removes leftover `type/` tags (should be `type:` field)
- Removes discipline-echo tags that duplicate directory position
- Removes structural/workflow tags (`curricula`, `stub`, `triage`, etc.)
- Converts tags to CamelCase
- Deduplicates tags

### Add type fields

```bash
python .claude/skills/manage-tags/add-type-tags.py
```

Adds `type:` frontmatter field based on directory location:

| Directory pattern | type value |
|---|---|
| `*/terms/` | `term` |
| `*/people/` | `person` |
| `*/concepts/` | `concept` |
| `*/schools/` | `school` |
| `*/topics/` | `topic` |
| `*/curricula/` | `lesson` |
| `*/text/` | `text` |
| `*/skills/` | `skill` |
| `personal/writing/babbles/` | `babble` |
| `personal/writing/letters-to-the-web/` | `letter` |
| `index.md` | `index` |

When multiple types apply, the most specific wins (term > concept > topic > index).

Both scripts are idempotent — running them again after no changes produces zero modifications.

## Instructions

1. If asked to clean tags, run `fix-tags.py` first, then `add-type-tags.py`.
2. Report the number of files modified and tags changed.
3. When creating new content, always include `type:` field and CamelCase tags.
