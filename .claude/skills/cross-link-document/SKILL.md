---
description: Add wikilinks, citations, and bibliography entries to a document by finding references to vault content and published sources
---

Cross-link this document: $ARGUMENTS

## Instructions

1. **Read the document** at `$ARGUMENTS`.

2. **Determine the content type** from the file's location (terms/, concepts/, text/,
   disciplines/, schools/, curricula/, encyclopedia/). Check the style guide's evidence
   standards for that content type.

3. **Identify linkable references.** Scan the text for:
   - **People** mentioned by name → link to `encyclopedia/people/` entries
   - **Concepts and terms** that have entries in the vault → link to the appropriate
     `terms/` or `concepts/` directory
   - **Works cited** by title or author → add `[@citekey]` references from
     `bibliography.bib`
   - **Disciplines and topics** referenced by name → link to their `index.md`

4. **Identify citation gaps.** Scan for:
   - **Unsourced factual claims** that should have a `[@citekey]` citation
   - **Term introductions** that don't cite who coined or defined the term
   - **Theoretical claims** attributed to thinkers but lacking a specific work citation
   - For each gap, search `bibliography.bib` for an existing entry. If none exists,
     propose a new BibTeX entry with a citekey of the form `authorYear`.

5. **Check that link targets exist.** For each proposed link:
   - Search for the target file: `find content -name "*slug*" -type f`
   - If the target doesn't exist, note it as a gap but don't create it automatically
   - For citations, search `bibliography.bib` for existing keys

6. **Present the proposed changes** in two tables:

   **Wikilinks:**

   | Line | Current text | Proposed link | Target exists? |
   |------|-------------|---------------|----------------|

   **Citations:**

   | Line | Claim | Proposed citation | In bibliography? | Action needed |
   |------|-------|-------------------|-------------------|---------------|

7. **Wait for confirmation.** emsenn may reject specific links or request different
   targets.

8. **Apply approved changes.** Use `[[wikilinks]]` for vault content and `[@citekey]`
   for bibliography references. Place citations after the sentence they support.
   Add any new BibTeX entries to `bibliography.bib`.

9. **Report** the number of links added, citations added, bibliography entries created,
   and any remaining gaps (references that should link somewhere but have no target,
   claims that need citation but no source was found).

### Rules

- Don't over-link. Link a term on its first substantive use in the document, not
  every occurrence.
- Don't link common words that happen to match a vault page (e.g., don't link "the"
  to a page titled "The").
- Prefer specific targets over generic ones (e.g., link to
  `sociology/terms/recursive-governance` not just `sociology/`).
- For people, use `[[Full Name]]` on first mention, consistent with the style guide.
- Citation gaps are the most important finding. Prioritize them over wikilinks.
