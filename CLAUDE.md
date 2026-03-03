# CLAUDE.md

Instructions for Claude Code and Claude agents working in this repository.

## Project Overview

This is **emsenn's** research site, built with [Quartz 4](https://quartz.jzhao.xyz/). The
`content/` directory is emsenn's Obsidian vault. The site is published at **emsenn.net**.

emsenn is a Lakota land steward and independent researcher. The central project is
**relationality** — a metaphysical and philosophical-mathematical framework, grounded in
Lakota epistemologies, that treats relations as ontologically prior to entities: things are
constituted through their relations rather than existing independently of them. Relationality
is developed both as philosophy and through formal mathematics, and it serves as the
conceptual foundation for the formal structures that organize this research. All agent work
should support that project.

## The Semioverse Hierarchy

The formal architecture underlying this vault is a hierarchy of mathematical structures,
each built on the last. Understanding this hierarchy tells you what belongs where.

**Semiotic Universe** — the pure mathematical bedrock. A complete Heyting algebra with
modal closure and Heyting-comonadic trace, extended with a typed lambda calculus and three
closure operators (semantic, syntactic, fusion) whose composite yields a least fixed point:
the initial semiotic structure. Concerns: sign relations, meaning, formal inference.
Lives at: `content/mathematics/objects/universes/semiotic-universe/`.

**Interactive Semioverse** — extends the Semiotic Universe with Things (external handles),
interaction terms, footprints (semantic closures of interactions), failure semantics,
provenance, and sheaf semantics. Concerns: how signs interact with external reality.
Lives at: `content/mathematics/objects/universes/interactive-semioverse/`.

**Agential Semioverse** — extends the Interactive Semioverse with agent profiles (role,
goals, policy, skills, tools, memory as fragment), tool signatures, skill calculus, and
execution semantics. Concerns: how agents act within and upon the semioverse.
Lives at: `content/mathematics/objects/universes/agential-semioverse/`.

**Agential Semioverse Repository (ASR)** — a concrete implementation of an Agential
Semioverse as an organized knowledge repository. This vault IS an ASR: its directory
structure, linking conventions, frontmatter schemas, and agent skills instantiate the
formal model. The specifications for how to organize this vault follow from the ASR
formalism. Operational specs live at:
`content/technology/specifications/agential-semioverse-repository/`.

The mathematics directories hold only the pure formal specifications. Implementation
documents, ideas, and operational theory belong in technology/specifications/.

## Repository Structure

`content/` is the Obsidian vault and primary working area. Its subdirectory structure
evolves — use `find content -mindepth 1 -maxdepth 2 -type d` to discover it. Each
directory may have an `index.md` whose `title:` frontmatter describes its purpose.

Fixed special directories:

- `assets/` — images and binary files
- `encyclopedia/` — reference entries (events, people, terms, times)
- `personal/` — emsenn's personal writing
- `writing/` — fiction
- `private/` — private notes, gitignored, never touch
- `slop/` — AI agent workspace (see below)
- `triage/` — unprocessed inbox (see below)
- `meta/` — Obsidian templates and Copilot prompts, not published
- `tags/` — Quartz tag index pages

Discipline modules live directly at the content root (e.g. `cosmology/`, `ecology/`,
`linguistics/`, `mathematics/`, `philosophy/`, `sociology/`, `technology/`, etc.). The
list grows over time; discover it with `find`.

Outside `content/`:

- `quartz/` — Quartz framework source, do not modify without explicit instruction
- `quartz.config.ts` / `quartz.layout.ts` — site configuration, leave alone unless asked

## Content That Is Not Published

Quartz is configured to ignore these directories:

- `content/private/` — also gitignored
- `content/meta/`
- `content/slop/`
- `content/triage/`

## Discipline Directory Structure

Each discipline module follows a standard subdirectory structure. The full specification
is at `content/technology/specifications/agential-semioverse-repository/directory-organization/`.
Standard subdirectories:

- `disciplines/` — formal subdisciplines
- `topics/` — areas of inquiry
- `schools/` — named theoretical traditions or thinkers
- `text/` — papers, essays, readings
- `concepts/` — individual concept notes
- `terms/` — glossary entries
- `curricula/` — structured learning sequences
- `history/` — cross-cutting; any module may have one; not a topic
- `specifications/` — formal specifications (used in `technology/`)

Special cases: `mathematics/objects/` for mathematical objects; `linguistics/languages/`
for natural language modules.

Do not place loose `.md` files at a discipline root. If a note's proper subdirectory does
not exist yet, create it with an `index.md` before placing the note.

## The slop/ Directory

`slop/` is the designated workspace for AI agents. Create and edit files freely here.
Content is not published and not expected to be polished. Put drafts, working notes, and
intermediate outputs here.

Do not move content out of `slop/` into published directories without explicit instruction.

## The triage/ Directory

`triage/` is an inbox for content that needs processing. Do not move or delete triage
content without explicit instruction. If asked to process triage content, consult emsenn
about destination before acting.

## Frontmatter

Notes use YAML frontmatter. Minimum required fields:

```yaml
title: Note Title
date-created: 2025-01-01T00:00:00
```

## Style

emsenn has a detailed style guide at `content/slop/emsemioverse-style-guide.md`. Key rules
for agent-generated writing:

- Write respectfully: don't tell the reader how to feel; acknowledge people have qualities
  but are not those qualities
- Use `emsenn` (lowercase, never capitalized)
- Use "use" not "utilize" unless something is being used in an unusual way
- Avoid vague adverbs: very, quite, clearly, completely, significantly, etc.
- Don't mix contractions with their spelled-out equivalents in the same piece
- Never form contractions from a noun and a verb (e.g., "emsenn's developing" is wrong)
- Prefer active voice and direct phrasing

When writing or editing content intended for publication, read the full style guide first.

## Git Conventions

- Work directly on `main`. Do not create git worktrees or feature branches unless
  explicitly asked. emsenn edits the vault concurrently in Obsidian; check `git status`
  before staging to account for recent changes.
- Binary files (images, PDFs, STLs, etc.) are tracked with Git LFS — handled automatically
- `content/private/` is gitignored — never stage files from there
- `.claude/worktrees/` and `.claude/projects/` are gitignored; `.claude/skills/` is tracked

## What Not to Touch

- `content/private/` — private notes, not in git
- `quartz/` — framework code, leave alone unless specifically asked
- `quartz.config.ts` / `quartz.layout.ts` — site configuration, leave alone unless asked
- Obsidian metadata in `content/.obsidian/` — leave alone
- `content/mathematics/objects/universes/*/` — pure formal specs; do not add
  implementation or operational content here
