---
description: Improve an existing skill based on what was learned during execution
id: improve-skill
version: [0, 1]
kind: meta
runtime: inference
triggers:
  - "improve skill"
  - "fix skill"
  - "update skill"
inputs:
  skill_id: string
  improvement: string?
outputs:
  changes: string[]
region:
  reads: [".claude/skills/", "content/**/skills/"]
  writes: [".claude/skills/", "content/**/skills/"]
dependencies: []
scopes: []
---
Improve skill: $ARGUMENTS

## Instructions

1. Read the skill's SKILL.md.
2. Identify what needs to change (from $ARGUMENTS or from the
   current session's experience using the skill).
3. Edit the SKILL.md. Preserve the frontmatter structure (id, region,
   dependencies).
4. If the skill needs a new script, write it alongside SKILL.md
   or in a `scripts/` subdirectory.
5. If the skill's description changed, update `.claude/skills/registry.md`.
6. Report what changed and why.
