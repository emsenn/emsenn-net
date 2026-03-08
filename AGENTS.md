# AGENTS.md

Complete operating manual for AI agents working in this repository.

## The emsemioverse

This repository is the **emsemioverse** — a semiotic endeavor conducted
by emsenn, a Lakota land steward and independent researcher.

An **endeavor** is an organized, sustained, intentional effort whose
purpose is immanent (discovered through the work, not assigned from
outside), with no guaranteed outcome and no fixed end. The emsemioverse
is not a project (projects end) and not an enterprise (enterprises
capture outcomes).

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
  are the method. These documents (AGENTS.md, CLAUDE.md) are part of
  the method.
- **Practice**: the actual doing of work according to method. Each
  agent session is practice — method applied to a concrete situation.
- **Project**: a bounded effort that ends when an internally controlled
  condition is met (e.g., "write the PM spec").
- **Operation**: a bounded effort that ends when an external condition
  is met (e.g., "get the PM system working across sessions").

### Formal structure

The repository is organized as an **Agential Semioverse Repository
(ASR)** — instantiating a formal hierarchy of mathematical structures:

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

| Directory | Purpose | Published |
|-----------|---------|-----------|
| `content/general/` | Cross-disciplinary reference | yes |
| `content/personal/` | Personal writing | yes |
| `content/writing/` | Style guides, conventions | yes |
| `content/assets/` | Images and binary files | yes |
| `content/slop/` | AI working area (drafts) | no |
| `content/triage/` | Unprocessed inbox | no |
| `content/meta/` | Obsidian templates | no |
| `content/private/` | Private notes (gitignored) | no |

Discipline modules (`mathematics/`, `philosophy/`, `technology/`, etc.)
live at `content/` root. Each follows a standard structure:
`disciplines/`, `topics/`, `schools/`, `texts/`, `terms/`, `concepts/`,
`curricula/`, `history/`. Full spec at
`content/technology/specifications/agential-semioverse-repository/directory-organization/`.

**Special directories**: `slop/` is the agent workspace (drafts, working
notes — never use as source of truth). `triage/` is an inbox — do not
move or delete without instruction. Do not place loose `.md` files at
discipline roots.

### Content organization

Each piece of content is written as what it is within its own
discipline. A math page is mathematics. A semiotics term is
linguistics. Write content neutrally — do not orient it around
"here is how this connects to the project." The network of typed
relations does the connecting; the pages do the defining.

## The encoding loop

Every message from emsenn is input to the emsemioverse. The agent's
job is to **encode meaning as content**: extract terms, write texts,
refine concepts, identify research questions, then execute actions.
Discussing ideas without producing artifacts is not encoding.

## Conventions

### Links and frontmatter

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

### Style

Read `content/writing/texts/style-guide.md` before writing published
content. Key rules: use `emsenn` (lowercase), avoid vague adverbs,
prefer active voice, lead with philosophy not mathematics, write
discipline-neutral content, no Lakota grounding in agent writing.

## Plans and session state

Work is tracked through plans at
`content/technology/specifications/agential-semioverse-repository/plans/`.
Plans track **projects** (bounded efforts ending when an internally
controlled condition is met) and **operations** (bounded efforts ending
when an external condition is met).

Session progress is recorded in each plan's `## Log` section.
Architectural choices are recorded as decision records at
`plans/decisions/`. There is no separate session-notes file — the
plans, decisions, and texts ARE the session record.

## Policies

Standing commitments live at
`content/personal/projects/emsemioverse/policies/`. Claude Code agents
get these loaded automatically via `.claude/rules/policies/`. Other
agents should read the policies directory directly.

## Build

```bash
nvm install --lts && nvm use --lts && npm install
```

Do not run `npx quartz build` unless explicitly asked — builds are slow.

## Git

- Work on `main` unless told otherwise
- emsenn edits concurrently — check `git status` before staging
- `content/private/` is gitignored; never stage
- Binary files tracked with Git LFS

## Priority

When encountering conflicting information: more recent wins, emsenn's
writing wins above that, asking emsenn wins above everything.

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
- Search `content/` for existing pages before writing — the vault
  already defines many concepts and constraints. Read before writing.
