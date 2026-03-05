---
description: Review a note against emsenn's style guide and report violations with line numbers and suggested fixes
id: check-note-style
version: [0, 1]
kind: operational
runtime: inference
triggers:
  - "check style"
  - "review style"
  - "style check"
inputs:
  path: string
outputs:
  violations: object[]
  summary: object
region:
  reads: ["content/", "content/writing/text/style-guide.md"]
  writes: []
dependencies: []
scopes: []
---
Check the style of: $ARGUMENTS

## Instructions

1. Read the file at `$ARGUMENTS`.
2. Read the style guide at `content/writing/text/style-guide.md`.
3. Determine the content type from the file's location:
   - `terms/` → term definition
   - `concepts/` → concept note
   - `text/` → essay or paper
   - `curricula/` → lesson
   - `disciplines/` → discipline page
   - `schools/` → school page
   - `encyclopedia/` → encyclopedia entry
   - `personal/writing/babbles/` → babble (relaxed standards — skip structural and citation checks)
   - `personal/writing/letters-to-the-web/` → letter (relaxed standards)

4. Check for violations of the following rules, noting line numbers:

**Voice and word choice**
- Vague adverbs: clearly, completely, exceedingly, extremely, fairly, hugely, interestingly, largely, literally, many, mostly, quite, relatively, remarkably, several, significantly, substantially, surprisingly, tiny, various, vast, very
- "utilize" where "use" would serve (flag unless the unusual-use sense is clearly intended)
- Telling the reader how to feel ("fascinating," "remarkable," "importantly")

**Contractions**
- Mixed contractions and spelled-out equivalents in the same piece (e.g., "don't" alongside "cannot")
- Contractions formed from a noun and verb (e.g., "emsenn's developing")
- Ambiguous contractions: there'd, it'll, they'll

**Proper nouns and identity**
- "emsenn" capitalized as "Emsenn" or "EMSENN"
- Describing a person as being a quality rather than having a quality
- First mention of a person uses surname only instead of full name (e.g., "Peirce" instead of "Charles Sanders Peirce"). Subsequent mentions may use surname only.

**Adjective order**
- Adjectives not following the prescribed order: quantity → opinion → size → quality → shape → age → color → origin → material → type → purpose

**Evidence and citation** (skip for babbles and letters)
- Unsourced factual claims that lack a `[@citekey]` citation
- Term definitions that don't cite who introduced the term
- Concept notes or essays with sections that lack any citations
- Discipline pages missing a "Methods" section
- School pages missing "Methods and approach" or "Key texts" sections
- Encyclopedia entries with unsourced factual claims not marked `[citation needed]`

**Content-type structure** (check against the style guide's content-type templates)
- Term definitions: does it follow the opening sentence / elaboration / related terms structure?
- Lessons: does it have worked examples and self-check exercises?
- Discipline pages: does it describe methods, not just list subdirectories?
- School pages: does it describe the school's approach, not just list key thinkers?
- Index pages: is it acting as an essay instead of a navigation aid?

5. For each violation, report:
   - Line number
   - The offending text (quoted)
   - The applicable rule
   - A suggested fix

6. Summarize:
   - Total violations by category
   - Most critical issues (citation gaps tend to be the most important)
   - Overall assessment: does this note meet the vault's standards?

7. Do not rewrite the note. Report only.
