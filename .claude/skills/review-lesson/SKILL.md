---
description: Review a curriculum lesson against pedagogical criteria and report what it does well and what it lacks
---

Review the lesson at: $ARGUMENTS

## Instructions

1. Read the target lesson file.
2. Read the style guide at `content/writing/text/style-guide.md`.
3. Check the lesson against each criterion below. For each, note whether the lesson passes, partially passes, or fails, with specific line numbers and quotes.

## Pedagogical criteria

### Structure

- **Motivation before definition**: Does the lesson explain why the topic matters before introducing formal content? A lesson that opens with a definition or formula fails this check.
- **Prerequisites stated**: Are prerequisites listed? Are they specific about what the reader needs (not just "familiarity with X")?
- **Prerequisites achievable**: Do the linked prerequisite pages exist? Do they cover what this lesson assumes?
- **Scope**: Does the lesson focus on one core idea, or does it try to cover multiple topics? Count the number of distinct concepts introduced — more than 3-4 in a single lesson is a warning sign.

### Concept introduction

- **One at a time**: Are concepts introduced sequentially, each grounded before the next appears? Or are multiple new terms introduced in a single paragraph?
- **Concrete before abstract**: For each concept, is there an example or intuitive explanation before the formal definition?
- **Examples present**: Does each major concept have at least one concrete example?

### Engagement

- **Worked example**: Is there a full walkthrough applying the concepts? (Not just a definition followed by "for example, ..." but a multi-step demonstration.)
- **Exercises or checkpoints**: Can the reader test their understanding? Self-check questions, exercises, or prompts to try something count.
- **Active voice**: Does the lesson address the reader and invite participation, or does it read like a textbook passage?

### Connections

- **Wikilinks**: Are `[[wikilinks]]` used for terms, people, and related content? Count how many key terms lack links.
- **Citations**: Are scholarly claims attributed with `[@citekey]`? Flag unsourced claims that should be cited.
- **Sequence links**: Does the lesson say where it fits — what comes before and what comes next?

### Style

- Run the same checks as `/check-note-style`: vague adverbs, mixed contractions, noun+verb contractions, telling the reader how to feel.

## Output format

For each criterion, report:
- **Pass** / **Partial** / **Fail**
- Line number(s) and quoted text illustrating the finding
- A specific suggestion for improvement (if Partial or Fail)

At the end, provide a summary: what the lesson does well and what needs the most work.

Do not rewrite the lesson. Report only.
