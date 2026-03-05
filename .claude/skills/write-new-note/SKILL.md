---
description: Create a new note with correct frontmatter in the appropriate content directory
id: write-new-note
version: [0, 1]
kind: operational
runtime: inference
triggers:
  - "write a note"
  - "create a page"
  - "add a note about"
  - "write about"
inputs:
  subject: string
  destination: string?
outputs:
  path: string
region:
  reads: ["content/"]
  writes: ["content/{discipline}/"]
dependencies:
  - make-content-folder
scopes: []
---
Create a new note for: $ARGUMENTS

## Instructions

1. Run this now to see the current content structure, then pick the right destination:

```bash
find content -mindepth 1 -maxdepth 2 -type d ! -path "*/\.*" ! -path "*/private*" | sort | while read d; do title=$(grep "^title:" "$d/index.md" 2>/dev/null | head -1 | sed 's/title: //'); echo "$d${title:+  ($title)}"; done
```

2. Choose the destination directory based on the note subject.

3. Determine the register:
   - **PTGAE** (default for all published content): follow the style guide at `content/writing/text/style-guide.md`.
   - **emsenn's voice** (babbles, letters, personal writing): follow the voice notes at `content/personal/writing/style/voice-notes.md`.

4. Determine the content type from the destination directory and check the style guide for its structural template:
   - `terms/` → opening sentence + elaboration + related terms. Cite who introduced the term.
   - `concepts/` → organized under clear headings, cite sources per section.
   - `text/` → thesis + evidence + conclusion. Follow discipline-appropriate citation conventions.
   - `disciplines/` → opening + methods + key texts + key thinkers + subdirectory overview.
   - `schools/` → opening + methods/approach + key texts + key thinkers + relationship to vault + critiques.
   - `curricula/` → use the `write-lesson` skill instead.
   - `encyclopedia/` → factual, concise, every claim cited.
   - `personal/writing/babbles/` → relaxed structure, emsenn's natural voice.

5. If the destination subdirectory doesn't exist yet, create it with an `index.md` first (no loose `.md` files at discipline roots).

6. Derive a kebab-case filename. For babbles, match the date-time format of existing files (e.g., `2026-03-03-1400h.md`).

7. Write the file with frontmatter:
   ```yaml
   ---
   title: "Note Title"
   date-created: 2026-03-03T00:00:00
   tags:
     - [relevant tags]
   ---
   ```

8. Write the body following the content-type template. Include `[@citekey]` citations for factual claims. Check `bibliography.bib` for existing entries.

9. If the note is a discipline page or school page, prioritize the "Methods" section — this is the section most likely to be underdeveloped.

10. After writing, run `/check-note-style` on the new file.

11. Report the full path created and a summary of what was written.
