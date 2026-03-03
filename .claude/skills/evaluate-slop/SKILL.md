---
description: Evaluate a file or directory in slop/ and propose whether to promote, revise, or delete it
---

Evaluate slop content: $ARGUMENTS

## Instructions

1. **Read the content.** If `$ARGUMENTS` is a directory, list its files and read each one.
   If it is a file, read it.

2. **Assess against these criteria:**

   - **Substance**: Does the content contain original ideas, formal specifications, or
     useful drafts? Or is it boilerplate, placeholder text, or incoherent output?
   - **Maturity**: Is it close to publishable, or does it need significant revision?
   - **Placement**: If it were to be promoted, where in the vault does it belong? Check
     the existing discipline structure.
   - **Overlap**: Does content in the published vault already cover this ground? Search
     for related files:
     ```bash
     grep -r "[key terms from the slop content]" content/ --include="*.md" -l | grep -v slop/
     ```
   - **Dependencies**: Does the content reference or depend on other slop files? Would
     promoting it require promoting those too?

3. **Propose a disposition** for each file:

   | Disposition | When to use |
   |---|---|
   | **Promote** | Content is substantive and ready (or nearly ready) for its target location |
   | **Revise then promote** | Good ideas but needs rewriting, restructuring, or deduplication |
   | **Extract** | Some parts are valuable; extract those and discard the rest |
   | **Archive** | Not useful now but might be later; leave in slop/ |
   | **Delete** | No value; remove |

   For each file, state:
   - The disposition
   - The target path (for promote/revise/extract)
   - What work is needed (for revise/extract)
   - Why (for archive/delete)

4. **Present the proposal to emsenn.** Do not move, edit, or delete any files without
   explicit confirmation.

5. **After confirmation**, execute the approved actions:
   - For promotions: use `git mv`, ensure the target has an `index.md`, update frontmatter
   - For revisions: edit in place in slop/, then move after review
   - For extractions: create the new file in the target location, leave the slop original
   - For deletions: `git rm` the file
