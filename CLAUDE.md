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
- `general/` — cross-disciplinary reference entries (events, people, terms, times)
- `personal/` — emsenn's personal writing
- `writing/` — writing as a discipline (style guides, content-type conventions)
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
- `questions/` — persistent inquiry-shaping questions tracked as independent objects
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

## Tags

Tags are cross-cutting thematic discovery labels, modeled on academic journal keywords.
They signal which conceptual communities a page participates in, enabling readers and
crawlers to find related content across structural boundaries.

Tag conventions:

- **CamelCase**: capitalize every word including articles and prepositions
  (`PoliticalTheory`, `SettlerColonialism`, `ArchiveOfOurOwn`)
- **Flat**: no `/` separators, no hierarchy — `Anarchism` not `Sociology/Anarchism`
- **3-5 per page** (max 10)
- **Most-specific first**: order tags from most specific to least specific
- **Cross-cutting only**: never duplicate directory position (a file in `mathematics/`
  does not need a `Mathematics` tag)
- **From the vocabulary**: prefer existing tags at `content/tags/` over inventing new ones

Content type is a separate `type:` frontmatter field, not a tag:

```yaml
type: term
tags:
  - Anarchism
  - PoliticalTheory
```

Full specification at `content/technology/specifications/agential-semioverse-repository/semantic-frontmatter.md`.

## Style

The vault uses three writing registers:

- **PTGAE** (Plain Technical General American English) — the formal register for all
  published vault content. Full guide at `content/writing/text/style-guide.md`.
  Agent-generated content for publication follows PTGAE unless told otherwise.
- **Voice Notes** — observations on emsenn's natural writing voice, at
  `content/personal/writing/style/voice-notes.md`. Use when writing in emsenn's
  personal register (babbles, letters-to-the-web, personal essays).
- **Polemic Register** — emsenn's mode for political analysis and institutional critique,
  at `content/personal/writing/style/polemic-register.md`.

Key PTGAE rules for agent-generated writing:

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

## Skills

Skills are the vault's executable capabilities. They live in two places:

- **Core agent skills** in `.claude/skills/` — operational skills for vault maintenance
  (auditing, creating content, committing, style checking, lesson writing)
- **Content-embedded skills** throughout `content/` — domain skills that live alongside
  the content they operate on (e.g., `content/mathematics/.../skills/learn-*/SKILL.md`)

Each skill is a `SKILL.md` file in a directory named for the skill. Skills have typed
inputs and outputs, declare dependencies, and specify a runtime.

### Skill-First Workflow

Before performing any non-trivial operation, follow this protocol:

1. **Check for an existing skill.** Search `.claude/skills/` and `content/**/SKILL.md`
   for a skill that matches the operation.
2. **If a skill exists, read it.** Verify that it does exactly what the current task
   requires — not approximately, exactly.
3. **If the skill is close but not right, improve it.** Update the skill to handle the
   current case correctly. This is not a detour; it is the work. Every skill improvement
   makes the next invocation better.
4. **If no skill exists, consider creating one.** If the operation is likely to recur or
   encodes knowledge about how the vault works, write a SKILL.md before doing the work
   manually. Use `/write-learn-skill` for learning skills; model new operational skills
   on the patterns in `.claude/skills/`.
5. **Then execute using the skill.** Follow the skill's instructions rather than
   improvising.

### Accreting Knowledge

Agent sessions surface information about how the vault should work — directory placement
rules, frontmatter conventions, linking patterns, stylistic preferences, domain
relationships. This information should not vanish when the session ends. Encode it:

- **Operational rules** → CLAUDE.md or the ASR spec at
  `content/technology/specifications/agential-semioverse-repository/`
- **Recurring operations** → SKILL.md files
- **Executable tooling** → Python scripts in `scripts/`
- **Formal specifications** → Lean or Agda code when the mathematics is stable enough

The goal is to move progressively from ad hoc agent work toward interactions mediated
entirely by well-defined ASR functions.

## What Not to Touch

- `content/private/` — private notes, not in git
- `quartz/` — framework code, leave alone unless specifically asked
- `quartz.config.ts` / `quartz.layout.ts` — site configuration, leave alone unless asked
- Obsidian metadata in `content/.obsidian/` — leave alone
- `content/mathematics/objects/universes/*/` — pure formal specs; do not add
  implementation or operational content here
