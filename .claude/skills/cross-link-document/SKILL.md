---
description: Add wikilinks and citations to a document by finding references to vault content and bibliography entries
---

Cross-link this document: $ARGUMENTS

## Instructions

1. **Read the document** at `$ARGUMENTS`.

2. **Identify linkable references.** Scan the text for:
   - **People** mentioned by name → link to `encyclopedia/people/` entries
   - **Concepts and terms** that have entries in the vault → link to the appropriate
     `terms/` or `concepts/` directory
   - **Works cited** by title or author → add `[cite:@key]` references from
     `bibliography.bib`
   - **Disciplines and topics** referenced by name → link to their `index.md`

3. **Check that targets exist.** For each proposed link:
   - Search for the target file: `find content -name "*slug*" -type f`
   - If the target does not exist, note it as a gap but do not create it automatically
   - For citations, search `bibliography.bib` for existing keys

4. **Present the proposed links** as a table:

   | Line | Current text | Proposed link | Target exists? |
   |------|-------------|---------------|----------------|

5. **Wait for confirmation.** emsenn may reject specific links or request different
   targets.

6. **Apply approved links.** Use `[[wikilinks]]` for vault content and `[cite:@key]`
   for bibliography references. Follow citation placement conventions: `[cite:@key]`
   goes after the period of the sentence it supports.

7. **Report** the number of links added and any gaps (references that should link
   somewhere but have no target page yet).

### Rules

- Do not over-link. Link a term on its first substantive use in the document, not
  every occurrence.
- Do not link common words that happen to match a vault page (e.g., do not link "the"
  to a page titled "The").
- Prefer specific targets over generic ones (e.g., link to
  `sociology/terms/recursive-governance` not just `sociology/`).
- For people, use `[[Full Name]]` on first mention, consistent with the style guide.
