---
description: Create a new content folder with an index.md at the given path
---

Create a content folder at: $ARGUMENTS

1. If the directory does not exist, create it with `mkdir -p`.
2. Derive a title from the directory name: convert kebab-case to spaces, apply title case, preserve existing capitalisation.
3. Set aliases to the title-cased name and the literal directory name.
4. Present the proposed `index.md` to emsenn for confirmation before writing.
5. After confirmation, write `index.md`:

```yaml
---
title: <derived title>
aliases:
  - <Title Cased Name>
  - <directory-name>
---
```

Followed by a brief one-sentence description of the directory's contents. No heading. No plugin-managed fields.

6. Report the path written.
