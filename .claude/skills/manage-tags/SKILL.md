---
description: Clean, normalize, and add structural tags across the vault
---

Manage tags across the vault: $ARGUMENTS

## Scripts

Two colocated scripts handle tag operations:

### Fix broken tags

```bash
python .claude/skills/manage-tags/fix-tags.py
```

Normalizes and cleans tag values across the vault:
- Removes path-like tags (containing `/` or `.md` unless they are `type/` tags)
- Normalizes near-duplicates (`math` → `mathematics`, `Babble` → `babble`)
- Removes tags that are YAML field names, markdown links, or LaTeX
- Preserves proper noun tags (e.g., `Peirce`, `Lakota`)

### Add type tags

```bash
python .claude/skills/manage-tags/add-type-tags.py
```

Adds structural `type/` tags based on directory location:

| Directory pattern | Tag |
|---|---|
| `*/terms/` | `type/term` |
| `*/people/` | `type/person` |
| `*/concepts/` | `type/concept` |
| `*/schools/` | `type/school` |
| `*/topics/` | `type/topic` |
| `*/curricula/` | `type/lesson` |
| `*/text/` | `type/text` |
| `personal/writing/babbles/` | `type/babble` |
| `personal/writing/letters-to-the-web/` | `type/letter` |
| `index.md` | `type/index` |

Both scripts are idempotent — running them again after no changes produces zero modifications.

## Tag taxonomy

The vault uses a hierarchical tag system with these families:

- `type/` — structural document type (term, person, concept, index, etc.)
- Content-specific tags (e.g., `mathematics`, `sociology`, `babble`)

## Instructions

1. If asked to clean tags, run `fix-tags.py` first, then `add-type-tags.py`.
2. If asked to add a new tag family, update the `add-type-tags.py` script.
3. Report the number of files modified and tags changed.
