---
description: Write a new curriculum lesson with sound pedagogical structure in the appropriate module
---

Write a lesson on: $ARGUMENTS

## Instructions

1. Read the style guide at `content/writing/text/style-guide.md`.

2. Identify the destination module. Run:

```bash
find content -mindepth 1 -maxdepth 2 -type d ! -path "*/\.*" ! -path "*/private*" ! -path "*/slop*" ! -path "*/triage*" ! -path "*/meta*" ! -path "*/tags*" ! -path "*/assets*" | sort
```

3. Read the destination module's existing `curricula/index.md` to understand what lessons exist, what sequence they follow, and what ground is already covered.

4. Read any prerequisite lessons that the new lesson will build on.

5. Propose a lesson plan to emsenn before writing. The plan should include:
   - Title
   - Where it fits in the existing sequence
   - What single core idea the lesson teaches
   - What prerequisites are assumed
   - What the worked example will be

6. After confirmation, write the lesson following this structure:

### Required lesson structure

**Frontmatter:**
```yaml
---
title: "Lesson Title"
date-created: [current ISO 8601]
tags:
  - [module tag]
  - curricula
---
```

**Body sections, in order:**

- **What this lesson covers** — 1-2 sentences. No jargon. A reader should know from this whether the lesson is for them.

- **Why it matters** — Motivation before definitions. What problem does this concept solve? What would be harder or impossible without it? Use a concrete scenario or historical example. Do not say "this is important because" — show why through a situation.

- **Prerequisites** — List as `[[wikilinks]]`. For each, note what specifically the reader needs from it (not just "familiarity with X" but "the definition of X and how Y works").

- **Core concepts** — Introduce ONE concept at a time. For each concept:
  1. Start with an intuitive explanation using plain language or analogy
  2. Give a concrete example the reader can hold in their head
  3. Only then give the formal definition (if applicable)
  4. Do not introduce the next concept until this one is grounded

- **Worked example** — A full walkthrough applying the lesson's concepts to a specific case. Show each step. Name what concept is being used at each step. The reader should be able to follow along and reproduce the reasoning.

- **Check your understanding** — 2-3 questions. These are self-checks, not exam questions. Each should test whether the reader grasped a specific concept. Include brief answers or hints in a details block.

- **Common mistakes** — What learners typically get wrong with this material. Be specific: "Confusing X with Y" not "misunderstanding the concept."

- **What comes next** — 1-2 sentences linking to the next lesson in the sequence.

### Rules

- One core idea per lesson. If you find yourself writing "now we turn to a different topic," the lesson is too big. Split it.
- Concrete before abstract. Every definition should be preceded by an example of what it defines.
- The reader does something. A lesson without exercises or a worked example is a reference document, not a lesson.
- Use `[[wikilinks]]` for all cross-references to terms, people, and other content.
- Use `[@citekey]` for all scholarly claims. Check `bibliography.bib` for existing entries; propose new ones if needed.
- Follow the style guide: no vague adverbs, no telling the reader how to feel, active voice.
- **First mention of a person uses their full name**: "Charles Sanders Peirce" not "Peirce," "Paulo Freire" not "Freire." Subsequent mentions may use surname only. Use `[[wikilinks]]` for the first mention (e.g., `[[Charles Sanders Peirce]]` or `[[Charles Sanders Peirce|Charles Sanders Peirce]]`).
- Do not frame the topic instrumentally (e.g., "this matters because the semioverse needs it"). Teach the subject as genuine knowledge.

7. After writing, run `/check-note-style` on the new file.
8. Update the module's `curricula/index.md` to include the new lesson in the sequence.
