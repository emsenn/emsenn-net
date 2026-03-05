---
title: "Skills Registry"
type: index
description: Machine-readable skill registry for prompt routing
---

# Skills Registry

When a prompt arrives, match it against these patterns to find the
right skill. Skills are grouped by intent category.

## Create

| Skill | Triggers | Input |
|-------|----------|-------|
| write-new-note | "write a note", "create a page", "add a term/concept" | topic or title |
| write-lesson | "write a lesson", "teach about" | topic + discipline |
| write-learn-skill | "create a learning skill", "add to curriculum" | topic + discipline |
| make-content-folder | "create a folder", "make directory" | path |

## Maintain

| Skill | Triggers | Input |
|-------|----------|-------|
| fix-frontmatter | "fix frontmatter", "fix metadata" | path or glob |
| manage-tags | "fix tags", "normalize tags", "add type fields" | path or "all" |
| cross-link-document | "cross-link", "add links to" | file path |
| audit-vault-references | "find broken links", "audit references" | none (vault-wide) |
| audit-content-folders | "find missing indexes", "audit folders" | none (vault-wide) |

## Review

| Skill | Triggers | Input |
|-------|----------|-------|
| check-note-style | "check style", "review style" | file path |
| review-lesson | "review lesson", "audit lesson" | file path |
| walk-the-site | "walk the site", "check the site" | starting path |

## Process

| Skill | Triggers | Input |
|-------|----------|-------|
| evaluate-slop | "evaluate slop", "assess draft" | file or dir in slop/ |
| process-triage-note | "process triage", "sort triage" | file in triage/ |

## Organize

| Skill | Triggers | Input |
|-------|----------|-------|
| restructure-discipline | "restructure", "reorganize", "move discipline" | discipline path |
| stabilize | "stabilize" | any path in content/ |

## Meta

| Skill | Triggers | Input |
|-------|----------|-------|
| commit-repository | "commit", "save changes" | none |
| encode-learning | "encode this", "remember this", "update memory" | what to encode |
| improve-skill | "improve skill", "update skill" | skill id + what to change |

## Read / Understand

| Skill | Triggers | Input |
|-------|----------|-------|
| orient-to-area | "what's in", "show me", "explore" | path or discipline name |
| trace-derivation | "how does X derive", "what produces X" | concept name |

## Format / Validate

| Skill | Triggers | Input |
|-------|----------|-------|
| generate-rdf | "generate TTL", "extract RDF" | file path |
| validate-thing | "validate", "check constraints" | path |

## Routing rules

1. If the prompt starts with `/`, it names a skill directly.
2. If the prompt matches a trigger phrase, route to that skill.
3. If the prompt is a correction (see `memory/interaction-patterns.md`),
   stop and fix the error before routing.
4. If the prompt is meta-commentary, update infrastructure files.
5. If no skill matches, ask emsenn what operation they want.
