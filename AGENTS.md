# AGENTS.md

Instructions for AI agents working in this repository.

## Project

Quartz 4 static site publishing emsenn's research from an Obsidian vault.
Live at **emsenn.net**. The `content/` directory is the vault and primary
working area. See `CLAUDE.md` for full project context and session-start
procedure.

## Build

```bash
nvm install --lts && nvm use --lts && npm install
```

Do not run `npx quartz build` unless explicitly asked — builds are slow.

## How this repository works

This vault is an **Agential Semioverse Repository (ASR)**. The
specifications at
`content/technology/specifications/agential-semioverse-repository/`
define how the vault is organized, how agents interact with it, and
what governance structures constrain work.

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
Session progress is recorded in each plan's `## Log` section.
Architectural choices are recorded as decision records at
`plans/decisions/`. There is no separate session-notes file — the
plans, decisions, and texts ARE the session record.

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
