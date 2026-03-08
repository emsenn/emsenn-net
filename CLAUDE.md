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

## The emsemioverse

This repository is the **emsemioverse** — a semiotic endeavor conducted
by emsenn, a Lakota land steward and independent researcher.

An **endeavor** is an organized, sustained, intentional effort whose
purpose is immanent — discovered through the work itself, not assigned
from outside. The emsemioverse is not a project (projects end) and not
an enterprise (enterprises capture outcomes). It is an ongoing effort
with no guaranteed outcome and no fixed end.

The endeavor's central concern is **relationality** — a philosophical-
mathematical framework treating relations as ontologically prior to
entities. All agent work supports this.

### Key terms

These have precise secondary intensions. Full definitions at
`content/technology/specifications/semiotic-endeavor/terms/`.

- **Endeavor**: the organized, sustained activity. The emsemioverse is
  this.
- **Repository**: the structured, versioned artifact the endeavor
  produces. This git repo and its content are the repository — the
  endeavor's body, not its activity.
- **Method**: the system of conventions governing how the endeavor
  conducts itself. The semiotic-* specifications, policies, and skills
  are the method. These documents (CLAUDE.md, AGENTS.md) are part of
  the method.
- **Practice**: the actual doing of work according to method. Each
  agent session is practice — method applied to a concrete situation.
- **Project**: a bounded effort that ends when an internally controlled
  condition is met (e.g., "write the PM spec").
- **Operation**: a bounded effort that ends when an external condition
  is met (e.g., "get the PM system working across sessions").

### Formal structure

The repository is organized as an **Agential Semioverse Repository
(ASR)** — a formal hierarchy of mathematical structures:

semiotic universe → interactive semioverse → agential semioverse → ASR

Specs: `content/technology/specifications/agential-semioverse-repository/`.
Mathematical specs: `content/mathematics/objects/universes/`.
The semiotic-endeavor spec: `content/technology/specifications/semiotic-endeavor/`.

### The endeavor's method

The semiotic-* specification family defines the method:

- **semiotic-endeavor** — what an endeavor is; organizational levels
- **semiotic-markdown** — how files carry semantic structure
- **semiotic-specification** — how conventions are documented
- **semiotic-project-management** — how work is planned and tracked
- **semiotic-versioning** — how artifacts are versioned
- **semiotic-changelog** — how changes are tracked

These live at `content/technology/specifications/semiotic-*/`.

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
This skill implements the encoding loop — the endeavor's practice of
turning input into encoded meaning: extract meaning from the message,
write texts, refine terms/concepts, identify research questions, then
execute actions. The user's words are the primary input to the
emsemioverse — encode them as content, don't just discuss them.

## Recording session state

Session progress accretes in the repository — the endeavor's artifact —
not in ephemeral conversation.

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

Skills are part of the endeavor's method — codified capabilities at
`SKILL.md` files in `content/`. Registry at `.claude/skills/registry.md`.
Prompts starting with `/` name a skill directly. The ASR theory
documents at
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
