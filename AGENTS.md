# AGENTS.md

Instructions for AI agents working in this repository.

## The emsemioverse

This repository is the **emsemioverse** — a semiotic endeavor conducted
by emsenn. An **endeavor** is an organized, sustained, intentional effort
whose purpose is immanent (discovered through the work, not assigned from
outside), with no guaranteed outcome and no fixed end.

The site is built with Quartz 4 and published at **emsenn.net**. The
`content/` directory is an Obsidian vault and the primary working area.
See `CLAUDE.md` for full context and session-start procedure.

## Build

```bash
nvm install --lts && nvm use --lts && npm install
```

Do not run `npx quartz build` unless explicitly asked — builds are slow.

## Method and practice

The endeavor's **method** is the system of conventions governing how work
is done. The endeavor's **practice** is the actual doing of work according
to that method. Each agent session is practice.

### The semiotic-* specifications

The method is defined by the semiotic-* specification family at
`content/technology/specifications/semiotic-*/`:

- **semiotic-endeavor** — what an endeavor is; organizational levels
- **semiotic-markdown** — how files carry semantic structure
- **semiotic-specification** — how conventions are documented
- **semiotic-project-management** — how work is planned and tracked
- **semiotic-versioning** — how artifacts are versioned
- **semiotic-changelog** — how changes are tracked

Full definitions of terms (endeavor, repository, method, practice,
project, operation) at
`content/technology/specifications/semiotic-endeavor/terms/`.

### The encoding loop

Every message from emsenn is input to the emsemioverse. The agent's
job is to **encode meaning as content**: extract terms, write texts,
refine concepts, identify research questions, then execute actions.
Discussing ideas without producing artifacts is not encoding.

### Policies

Standing commitments live at
`content/personal/projects/emsemioverse/policies/`. These are loaded
automatically for Claude Code agents via `.claude/rules/policies/`.
Other agents should read the policies directory directly.

### Plans and session state

Work is tracked through plans at
`content/technology/specifications/agential-semioverse-repository/plans/`.
Plans track **projects** (bounded efforts ending when an internally
controlled condition is met) and **operations** (bounded efforts ending
when an external condition is met). Session progress is recorded in each
plan's `## Log` section. Architectural choices are recorded as decision
records at `plans/decisions/`. There is no separate session-notes file —
the plans, decisions, and texts ARE the session record.

### Formal structure

The repository is organized as an **Agential Semioverse Repository
(ASR)** — instantiating a formal hierarchy of mathematical structures:

semiotic universe → interactive semioverse → agential semioverse → ASR

Specs: `content/technology/specifications/agential-semioverse-repository/`.
Mathematical specs: `content/mathematics/objects/universes/`.

### Content organization

Each piece of content is written as what it is within its own
discipline. A math page is mathematics. A semiotics term is
linguistics. Write content neutrally — do not orient it around
"here is how this connects to the project." The network of typed
relations does the connecting; the pages do the defining.

## Content structure

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

## Conventions

- Use relative-path markdown links: `[text](relative/path.md)`. Never
  generate wikilinks (`[[...]]`).
- Minimum frontmatter: `title:` and `date-created:` (ISO 8601)
- When updating a document: add `authors:` and `date-updated:`
- Tags: CamelCase, flat, 3-5 per page, most-specific first
- Work on `main` unless told otherwise
- Check `git status` before staging (emsenn edits concurrently)
- Large binaries tracked with Git LFS
- `content/private/` is gitignored — never stage
- Agent drafts go in `content/slop/`
- No loose `.md` files at discipline roots
- Search `content/` for existing pages before writing — the vault
  already defines many concepts and constraints
