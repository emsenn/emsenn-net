---
title: "Skills Registry"
type: index
description: Machine-readable skill registry for prompt routing
---

# Skills Registry

When a prompt arrives, match it against these patterns to find the
right skill. Skills are grouped by intent category.

## Create

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| write-new-note | `technology/specifications/semiotic-markdown/skills/write-new-note/` | "write a note", "create a page" | topic or title |
| write-lesson | `education/disciplines/pedagogy/skills/write-lesson/` | "write a lesson", "teach about" | topic + discipline |
| write-learn-skill | `education/disciplines/pedagogy/skills/write-learn-skill/` | "create a learning skill" | topic + discipline |
| make-content-folder | `technology/specifications/agential-semioverse-repository/skills/make-content-folder/` | "create a folder", "make directory" | path |
| record-idea | `technology/specifications/agential-semioverse-repository/skills/record-idea/` | "record idea", "idea about" | idea text + thing |
| create-skill | `technology/specifications/agential-semioverse-repository/skills/create-skill/` | "create skill", "new skill" | skill name + parent thing |
| create-plan | `technology/specifications/agential-semioverse-repository/plans/skills/create-plan/` | "create a plan", "plan for", "propose work on" | title + motivation |
| record-decision | `technology/specifications/agential-semioverse-repository/plans/skills/record-decision/` | "record a decision", "document this decision", "ADR for" | title + context |
| write-directory-agent-instructions | `technology/specifications/agential-semioverse-repository/skills/write-directory-agent-instructions/` | "write AGENTS.md for", "add agent instructions to", "create directory agent context" | directory path |

## Edit

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| edit-markdown | `technology/specifications/semiotic-markdown/skills/edit-markdown/` | "edit", "update", "add to", "modify" | file path + instruction |
| split-note | `technology/specifications/semiotic-markdown/skills/split-note/` | "split", "separate into", "break apart" | source file + target concepts |
| improve-skill | `technology/specifications/agential-semioverse-repository/skills/improve-skill/` | "improve skill", "update skill" | skill id + what to change |

## Maintain

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| fix-frontmatter | `technology/specifications/agential-semioverse-repository/skills/fix-frontmatter/` | "fix frontmatter", "fix metadata" | path or glob |
| manage-tags | `technology/specifications/agential-semioverse-repository/skills/manage-tags/` | "fix tags", "normalize tags" | path or "all" |
| cross-link-document | `technology/specifications/semiotic-markdown/skills/cross-link-document/` | "cross-link", "add links to" | file path |
| audit-vault-references | `technology/specifications/agential-semioverse-repository/skills/audit-vault-references/` | "find broken links", "audit references" | none |
| audit-content-folders | `technology/specifications/agential-semioverse-repository/skills/audit-content-folders/` | "find missing indexes", "audit folders" | none |
| audit-technical-debt | `technology/specifications/agential-semioverse-repository/skills/audit-technical-debt/` | "audit technical debt", "find technical debt", "what needs fixing" | scope? |
| tighten-specification | `technology/specifications/agential-semioverse-repository/skills/tighten-specification/` | "tighten specification", "tighten spec", "find spec gap", "underspecified", "specify" | scope? |

## Review

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| check-note-style | `technology/specifications/semiotic-markdown/skills/check-note-style/` | "check style", "review style" | file path |
| review-lesson | `education/disciplines/pedagogy/skills/review-lesson/` | "review lesson", "audit lesson" | file path |
| walk-the-site | `technology/specifications/agential-semioverse-repository/skills/walk-the-site/` | "walk the site", "check the site" | starting path |
| check-skill | `technology/specifications/agential-semioverse-repository/skills/check-skill/` | "check skill", "validate skill" | skill id or --all |
| assess-page | `technology/specifications/agential-semioverse-repository/skills/assess-page/` | "assess", "audit page", "what would make this better" | path or random |

## Process

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| evaluate-slop | `technology/specifications/agential-semioverse-repository/skills/evaluate-slop/` | "evaluate slop", "assess draft", "check slop", "clean up slop" | file or dir in slop/ |
| process-triage-note | `technology/specifications/agential-semioverse-repository/skills/process-triage-note/` | "process triage", "sort triage", "handle triage note", "what is this triage note" | file in triage/ |

## Organize

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| restructure-discipline | `technology/specifications/agential-semioverse-repository/skills/restructure-discipline/` | "restructure", "reorganize" | discipline path |
| stabilize | `technology/specifications/agential-semioverse-repository/skills/stabilize/` | "stabilize" | any path in content/ |

## Meta

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| commit-repository | `technology/specifications/agential-semioverse-repository/skills/commit-repository/` | "commit", "save changes" | none |
| encode-learning | `technology/specifications/agential-semioverse-repository/skills/encode-learning/` | "encode this", "remember this" | what to encode |
| better-emsemioverse | `personal/projects/emsemioverse/skills/better-emsemioverse/` | "better the emsemioverse" | area? |
| better-mathematical-universe | `mathematics/objects/universes/skills/better-mathematical-universe/` | "better mathematical universe", "improve the semiotic universe", "improve the semioverse" | universe name? |
| list-skills | `technology/specifications/agential-semioverse-repository/skills/list-skills/` | "list skills", "what skills" | thing path? |
| delete-skill | `technology/specifications/agential-semioverse-repository/skills/delete-skill/` | "delete skill", "remove skill" | skill id |

## Read / Understand

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| find-thing | `technology/specifications/agential-semioverse-repository/skills/find-thing/` | "find", "where is", "locate" | query string |
| orient-to-area | `technology/specifications/agential-semioverse-repository/skills/orient-to-area/` | "what's in", "show me", "explore" | path or discipline |
| trace-derivation | `technology/specifications/agential-semioverse-repository/skills/trace-derivation/` | "how does X derive" | concept name |
| learn-about-the-emsemioverse | `personal/projects/emsemioverse/skills/learn-about-the-emsemioverse/` | "learn about the emsemioverse", "what is the emsemioverse" | none |

## Format / Validate

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| generate-rdf | `technology/specifications/semiotic-markdown/skills/generate-rdf/` | "generate rdf", "create turtle", "convert to ttl", "generate ttl", "build rdf" | path?, --all, --dry-run, --stats, --force, --combined |
| validate-thing | `technology/specifications/agential-semioverse-repository/skills/validate-thing/` | "validate", "check constraints" | path |
| validate-content | `technology/specifications/agential-semioverse-repository/skills/validate-content/` | "validate content", "check frontmatter", "run content validation" | path?, type?, errors-only? |
| enrich-mathematical-content | `mathematics/specifications/mathematical-agential-semioverse-repository/skills/enrich-mathematical-content/` | "enrich math", "add math frontmatter" | path |
| enrich-philosophical-content | `philosophy/specifications/philosophical-agential-semioverse-repository/skills/enrich-philosophical-content/` | "enrich philosophy", "add philosophy frontmatter" | path |

## Routing rules

1. If the prompt starts with `/`, it names a skill directly.
2. If the prompt matches a trigger phrase, route to that skill.
3. If the prompt is a correction (frustration signals, "stop doing X"),
   stop and fix the error before routing.
4. If the prompt is meta-commentary, update infrastructure files.
5. If no skill matches, ask emsenn what operation they want.

### Compound prompts

When a prompt contains multiple operations joined by "and then" or
commas, decompose it into a sequence of skill invocations. Execute
each skill in order, passing outputs forward as inputs where
applicable. Example:

> "Split X and Y into separate files, then write curricula, then
> write a learn skill"

Decomposes to: `/split-note` → `/write-lesson` → `/write-learn-skill`.

Read each skill before executing. If any step's output is needed as
input to the next step, pass it explicitly.

All paths are relative to `content/`. Each skill's `SKILL.md` is at
`content/{path}/SKILL.md`.
