# CLAUDE.md

Instructions for Claude Code agents working in this repository.

## Session start

Before doing ANY work, set up the environment. If setup fails, STOP and
tell emsenn — do not silently work around it or invent alternative work.

1. Initialize the content submodule: `git submodule update --init content`
   then `ls content/` to confirm files exist. If empty, stop.
2. Install dependencies: `nvm install --lts && nvm use --lts && npm install`
3. **Review plans**: run the review-plans skill at
   `content/technology/specifications/agential-semioverse-repository/plans/skills/review-plans/SKILL.md`.
   This shows all plans, their statuses, what's active, what's blocked.
   The active plan is what you should be working on unless emsenn says
   otherwise.
4. Run `git log --oneline -5` in both repos to see recent changes.

## Project

This is **emsenn's** research site (emsenn.net), built with Quartz 4.
`content/` is an Obsidian vault and the primary working area.

emsenn is a Lakota land steward and independent researcher. The central
project is **relationality** — a philosophical-mathematical framework
treating relations as ontologically prior to entities. All agent work
supports that project.

The vault is organized as an **Agential Semioverse Repository (ASR)** — a
formal hierarchy of mathematical structures (semiotic universe → interactive
semioverse → agential semioverse → ASR) that governs the vault's structure.
Specs live at `content/technology/specifications/agential-semioverse-repository/`.
Mathematical specs at `content/mathematics/objects/universes/`.

## Content structure

`content/` subdirectories evolve. Run `find content -mindepth 1 -maxdepth 2 -type d`
to discover them. Each may have an `index.md` with a `title:` field.

**Not published**: `private/` (also gitignored), `meta/`, `slop/`, `triage/`

**Special directories**: `slop/` is the agent workspace (drafts, working
notes — never use as source of truth). `triage/` is an inbox — do not
move or delete without instruction.

Discipline modules (`mathematics/`, `philosophy/`, `technology/`, etc.) live
at the content root. Each follows a standard subdirectory structure; full
spec at `content/technology/specifications/agential-semioverse-repository/directory-organization/`.
Do not place loose `.md` files at a discipline root.

## Links and frontmatter

Use `[text](relative/path.md)` for pages that exist. NEVER generate
wikilinks (`[[...]]`) — those are emsenn's placeholders only.

Minimum frontmatter:

```yaml
title: Note Title
date-created: 2025-01-01T00:00:00
```

When updating a document, add `authors: [claude]` and `date-updated:`.
Tags use CamelCase, flat, 3-5 per page, most-specific first. Full spec
at `content/technology/specifications/agential-semioverse-repository/semantic-frontmatter.md`.

## Style

Read `content/writing/texts/style-guide.md` before writing published
content. Key rules: use `emsenn` (lowercase), avoid vague adverbs,
prefer active voice, lead with philosophy not mathematics, write
discipline-neutral content, no Lakota grounding in agent writing.

## Policies

Standing commitments are loaded via `.claude/rules/policies/`. See
`content/personal/projects/emsemioverse/policies/` for full rationale.

## Priority

When encountering conflicting information: more recent wins, emsenn's
writing wins above that, asking emsenn wins above everything.

## Message handling

In response to every user message, apply the interpret-message skill at
`content/technology/specifications/agential-semioverse-repository/skills/interpret-message/SKILL.md`.
This skill implements the encoding loop: extract meaning from the
message, write texts, refine terms/concepts, identify research
questions, then execute actions. The user's words are the primary input
to the emsemioverse — encode them as content, don't just discuss them.

## Recording session state

Session progress lives in the repository, not in a single notes file.

- **Work progress**: append to the `## Log` section of each plan you
  work on. Record what was done, what was decided, and what remains.
- **Architectural choices**: write decision records at
  `content/technology/specifications/agential-semioverse-repository/plans/decisions/`.
- **Corrections from emsenn**: encode as decision records or policy
  revisions (at `content/personal/projects/emsemioverse/policies/`).
- **Key insights**: write texts in the appropriate discipline or
  project directory.
- **Active work state**: the plans system is the source of truth.
  The review-plans skill shows current state.

Do NOT maintain a separate working-notes or session-log file. The
plans, decisions, and texts ARE the session record.

## Skills and workflow

Skills are `SKILL.md` files in `content/`. Registry at
`.claude/skills/registry.md`. Prompts starting with `/` name a skill
directly. The ASR theory documents at
`content/technology/specifications/agential-semioverse-repository/theory/`
formalize prompt routing, skill interaction, and work-unit lifecycle.

Before any task, search `content/` for existing pages, specs, and research.
The repository already defines many concepts and constraints. Read before
writing.

## Git

- Work on `main` unless told otherwise
- emsenn edits concurrently — check `git status` before staging
- `content/private/` is gitignored; never stage
- Binary files tracked with Git LFS

## Do not

- Use slop/ as source of truth — verify against actual specs instead
- Impose taxonomies (Movements, Strata, Phases) on relationality — use
  the derivational graph (derivesFrom, produces, requires, incites)
- Treat drafts or AI-generated content as canonical
- Encode cheats in formal code (`noncomputable`, circular axioms, `sorry`)
  — if a proof does not work, say so
- Make up work — if there is no task, ask emsenn
- Act before reading existing specs and research
- Touch: `quartz/`, `quartz.config.ts`, `quartz.layout.ts`,
  `content/.obsidian/`, `content/private/`
- Add implementation content to `content/mathematics/objects/universes/*/`
  — implementation goes in `technology/specifications/`
