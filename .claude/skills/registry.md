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
| make-specification | `technology/specifications/specification-specification/skills/make-specification/` | "make specification", "create spec", "new specification", "write spec", "scaffold spec" | spec-id + category? + source_material[]? |
| make-semiotic-specification | `technology/specifications/semiotic-specification-specification/skills/make-semiotic-specification/` | "make semiotic specification", "create semiotic spec", "new semiotic specification", "write semiotic spec" | spec-id + category? + source_material[]? |
| create-skill | `technology/specifications/agential-semioverse-repository/skills/create-skill/` | "create skill", "new skill" | skill name + parent thing |
| write-term-or-concept | `technology/specifications/agential-semioverse-repository/skills/write-term-or-concept/` | "write term", "write concept", "define term", "create term file", "what does X mean (needs term entry)" | name + definition? + layer? |
| write-derivation-text | `technology/specifications/semiotic-endeavor/skills/write-derivation-text/` | "write derivation text", "document derivation", "trace what X contributes", "source of inspiration", "X inspires Y", "mark X as derivation source" | source + target? + type? |
| integrate-cross-domain-concept | `technology/specifications/semiotic-endeavor/skills/integrate-cross-domain-concept/` | "integrate concept", "bring X into endeavor spec", "what does X contribute to the endeavor", "how does X map to endeavor vocabulary" | concept + source domain? |
| create-plan | `technology/specifications/agential-semioverse-repository/plans/skills/create-plan/` | "create a plan", "plan for", "propose work on", "let's plan", "plan rewriting", "plan to" | title + motivation |
| review-plans | `technology/specifications/agential-semioverse-repository/plans/skills/review-plans/` | "review plans", "what are the plans", "plan status", "show plans", "show board" | none |
| situational-assessment | `technology/specifications/agential-semioverse-repository/plans/skills/situational-assessment/` | "assess situation", "where are we", "what should we do", "take stock", "what should I work on" | none |
| update-plan | `technology/specifications/agential-semioverse-repository/plans/skills/update-plan/` | "update plan", "log progress", "complete plan", "abandon plan" | plan number + action |
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
| enrich-triage | `technology/specifications/agential-semioverse-repository/skills/enrich-triage/` | "enrich triage", "clean up triage" | path?, batch? |
| mine-triage | `technology/specifications/agential-semioverse-repository/skills/mine-triage/` | "mine triage", "survey triage" | focus + lens |

## MCP tools (runtime: mcp)

| Skill | Path | MCP tool | Input |
|-------|------|----------|-------|
| find-in-repo | `technology/specifications/agential-semioverse-repository/skills/find-in-repo/` | `mcp__asr__find_in_repo` | query, discipline?, type? |
| query-triage-index | `technology/specifications/agential-semioverse-repository/skills/query-triage-index/` | `mcp__asr__query_triage_index` | enrichment?, discipline?, type?, status? |
| rebuild-triage-index | `technology/specifications/agential-semioverse-repository/skills/rebuild-triage-index/` | `mcp__asr__rebuild_triage_index` | none |
| list-plans | `technology/specifications/agential-semioverse-repository/skills/list-plans/` | `mcp__asr__list_plans` | status?, priority? |
| list-skills | `technology/specifications/agential-semioverse-repository/skills/list-skills/` | `mcp__asr__list_skills` | kind?, search? |
| validate-frontmatter | `technology/specifications/agential-semioverse-repository/skills/validate-frontmatter/` | `mcp__asr__validate_frontmatter` | path |
| delegate-task | `technology/specifications/agential-semioverse-repository/skills/delegate-task/` | `mcp__asr__delegate_task` | task, context? |
| mine-triage-relevance | `technology/specifications/agential-semioverse-repository/skills/mine-triage-relevance/` | `mcp__asr__mine_triage_relevance` | focus, directory?, threshold? |
| infer-triage-frontmatter | `technology/specifications/agential-semioverse-repository/skills/infer-triage-frontmatter/` | `mcp__asr__infer_triage_frontmatter` | batch?, dry_run?, file? |

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
| validate-plan-status | `technology/specifications/agential-semioverse-repository/plans/skills/validate-plan-status/` | "validate plans", "check plan status" | --verbose? |
| enrich-mathematical-content | `mathematics/specifications/mathematical-agential-semioverse-repository/skills/enrich-mathematical-content/` | "enrich math", "add math frontmatter" | path |
| enrich-philosophical-content | `philosophy/specifications/philosophical-agential-semioverse-repository/skills/enrich-philosophical-content/` | "enrich philosophy", "add philosophy frontmatter" | path |

## Default

| Skill | Path | Triggers | Input |
|-------|------|----------|-------|
| interpret-first-message | `technology/specifications/agential-semioverse-repository/skills/interpret-first-message/` | first message of session, session-opening message | user message |
| interpret-message | `technology/specifications/agential-semioverse-repository/skills/interpret-message/` | every subsequent user message (default) | user message |

## Routing rules

0. For the first message of a session, apply interpret-first-message
   to parse session goals, load targeted context, and set up the work
   cycle. For subsequent messages, apply interpret-message to extract
   and encode meaning.
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
