---
description: Create a learn-* skill that defines a node in the vault's curriculum dependency graph
---

Create a learn skill for: $ARGUMENTS

## Instructions

1. Identify the subject and where it lives in the vault. Run:

```bash
find content -mindepth 1 -maxdepth 2 -type d ! -path "*/\.*" ! -path "*/private*" ! -path "*/slop*" ! -path "*/triage*" ! -path "*/meta*" ! -path "*/tags*" ! -path "*/assets*" | sort
```

2. Check what lessons and terms already exist for the subject:

```bash
find content/[module]/[path] -name "*.md" -type f | sort
```

3. Identify prerequisite learn skills. Check what learn skills already exist:

```bash
find content -path "*/skills/learn-*/SKILL.md" -type f | sort
```

4. Propose the skill to emsenn before writing. The proposal should include:
   - Skill name (format: `learn-[subject]`)
   - Where it will live (in the subject's `skills/` directory)
   - Terminal learning goal (what the learner can DO after)
   - Prerequisite learn skills (with what specifically is needed from each)
   - Lessons the skill points to
   - What the skill does NOT cover (scope boundary)
   - Any lessons that need to be written (gaps)

5. After confirmation, write the skill following this structure:

### Required learn skill structure

**Location:** `content/[module]/[path]/skills/learn-[subject]/SKILL.md`

**Frontmatter:**
```yaml
---
name: learn-[subject]
description: >-
  One sentence: what the learner can do after completing this skill.
kind: skill
skill-kind: learning
date-created: [current ISO 8601 date]
tags:
  - [relevant tags]
---
```

**Body sections:**

```markdown
# Learn [Subject]

## What you will be able to do

[Specific, testable completion criteria. Not "understand X" but "do Y."
List 2-4 concrete things the learner can do after completing this skill.]

## Prerequisites

[List prerequisite learn skills. For each, state what specifically is needed.
Use the format:]

- **learn-[prerequisite]** — [what you need from it: "the definition of X and the ability to do Y"]

[If there are no prerequisites, say so explicitly: "None. This skill is a starting point."]

## Lessons

[List the lessons to work through, as [[wikilinks]]. Do NOT number them as a
forced sequence unless the dependency structure requires a specific order.
If multiple lessons are independent of each other, say so.]

- [[lesson-slug|Lesson Title]] — [one line: what this lesson teaches]

## Scope

[State what this skill covers and what it does not. Be honest about gaps —
subjects the medium cannot hold, traditions not represented, topics deferred
to other skills.]

## Verification

[How the learner (or agent) checks that the skill is complete. Point to
self-check exercises in the lessons, or state a concrete task the learner
should be able to perform.]
```

### Rules

- Each learn skill is a node in the dependency graph. It has edges (prerequisites) and a completion criterion.
- Prerequisites point to other learn skills, not to lessons. The skill handles the indirection: "to learn X, first complete learn-Y, then work through these lessons."
- Completion criteria are specific and testable. "Understand X" is not a completion criterion. "Given a Y, determine whether it is an X by checking properties P, Q, R" is.
- Scope is stated explicitly. Every skill excludes things; say what.
- Do not force linear order on independent lessons. If lessons A and B are independent, say "these can be done in either order."
- If a needed lesson does not exist yet, note it as a gap: "[Gap: no lesson on X exists yet. This skill is incomplete until one is written.]"
- If an existing learn skill for the same subject already exists (from gpt-5.2-codex), overwrite it — the old stubs are placeholders.

6. After writing, check that all referenced lessons and prerequisite skills actually exist. Report any gaps.
