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

**Interactive Semioverse** — extends the Semiotic Universe with handles (persistent external
indices for things), interaction terms, footprints (semantic closures of interactions), failure semantics,
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
- `texts/` — papers, essays, readings
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

## Linking

ALWAYS use markdown links `[text](relative/path.md)` for pages that exist. Wikilinks
`[[target]]` are used ONLY by emsenn as placeholders for pages that don't exist yet.
Agents must NEVER generate wikilinks — always resolve to a proper relative-path markdown
link. When emsenn writes `[[flipwidget]]`, that's a signal to create the page and convert
it to a markdown link.

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

When significantly updating a document, add yourself to `authors:` (as `claude`) and
set `date-updated:` to the current date. This tracks provenance — who wrote what and
when.

When searching for content, prioritize recent work, but with more weight, prioritize
things written by emsenn. The agent's job is to support emsenn's research, not to
foreground its own contributions. When you encounter contradicting information, apply
the same priority: more recent wins, emsenn's writing wins above that, and asking
emsenn wins above everything. The emsemioverse is the initial and experimental ASR —
contradictions are expected as the specification and implementation evolve together.

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
  published vault content. Full guide at `content/writing/texts/style-guide.md`.
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
- **Philosophy first**: the mathematics is one correspondence among possible ones. It
  validates; it is not the thing. Lead with what something IS in relational terms, then
  note the mathematical parallel.
- **Language boundaries**: the mathematical layers (semiotic universe through ASR) have
  their own vocabulary; relationality has its own. Do not let technical or mathematical
  terms overwrite the philosophical vocabulary of relationality. Use relational language
  when describing what something *is*, mathematical language when describing how it is
  *formalized*, and ASR language when describing how it is *implemented*. The emsemioverse
  exists in part to stabilize the language of relationality — if the infrastructure
  preempts the vocabulary it is meant to stabilize, the project undermines itself.
- **Discipline-neutral**: content within a discipline is written as that discipline's
  content, in plain technical general American English. Do not orient discipline content
  around "here is how this connects back to relationality" — those connections emerge
  from the semiotic network (links, typed relations, cross-domain `requires:`) as the
  repository grows. Write about technical debt as a software engineering concept, about
  Heyting algebras as mathematical objects, about care ethics as a philosophical position.
  The network does the connecting; the pages do the defining.
- **Self-standing**: a reader should never need access to source drafts to understand
  published content.
- **No Lakota grounding in agent writing**: that context is emsenn's to articulate.
  Agents write neutrally, as the constructor of the repository.

When writing or editing content intended for publication, read the full style guide first.

## Git Conventions

- Work directly on `main`. Do not create git worktrees or feature branches unless
  explicitly asked. emsenn edits the vault concurrently in Obsidian; check `git status`
  before staging to account for recent changes.
- Binary files (images, PDFs, STLs, etc.) are tracked with Git LFS — handled automatically
- `content/private/` is gitignored — never stage files from there
- `.claude/worktrees/` and `.claude/projects/` are gitignored; `.claude/skills/` is tracked

## Skills

Skills are the vault's executable capabilities. They live in `content/` alongside the
thing they operate on, in a `skills/{skill-name}/SKILL.md` directory structure. The
skills registry at `.claude/skills/registry.md` maps prompt patterns to skills for
routing.

Each skill is a `SKILL.md` file in a directory named for the skill. Skills have typed
inputs and outputs, declare dependencies, and specify a runtime.

### Prompt Routing

Every prompt from emsenn is a command. Parse it, route it to a skill, execute the
skill. The skills registry at `.claude/skills/registry.md` maps prompt patterns to
skills. The routing order:

1. If the prompt starts with `/`, it names a skill directly. Read and execute it.
2. Match the prompt against trigger phrases in the registry. Route to the best match.
3. If the prompt is a correction (frustration signals, "stop doing X", "I keep
   saying"), stop current work. Fix the error in a persistent file (skill,
   CLAUDE.md, or ASR spec). Encode the correction exactly as stated — don't
   paraphrase or reinterpret. Confirm the fix. Then resume.
4. If the prompt is meta-commentary ("I think we should..."), update infrastructure
   files (CLAUDE.md, ASR specs, skills).
5. If no skill matches, ask what operation emsenn wants. Don't guess.

**Before executing any routed skill or task**, read the repository for context:

- Search `content/` for existing pages, specs, and research relevant to the task.
  The triage/ directory contains extensive unpublished research — check it.
- Read the ASR specifications at
  `content/technology/specifications/agential-semioverse-repository/` for any
  formalism that governs the operation.
- Read the mathematical specifications if the task involves formal structures.
- Understand what already exists before writing anything new. The repository
  contains kilobytes of research that defines the concepts, structures, and
  constraints the agent must work within. Do not invent when the research
  already specifies.

Signal classification and dispatch are formalized in the
[prompt routing](content/technology/specifications/agential-semioverse-repository/theory/prompt-routing.md)
specification.

### Work Cycle

Each session works on ONE thing. The current task and its state live in
`content/personal/projects/emsemioverse/working-notes.md`. At the start of every
turn, re-read that file to know what you are working on — regardless of where
the previous turn ended.

The cycle for a unit of work:

1. **Pick one part of the ASR.** Not three, not "whatever seems related." One.
2. **Decide how it would have to be implemented** in a real repository given real
   tools (git, markdown, YAML frontmatter, Python scripts, TTL, Lean).
3. **Document that decision** in the working notes.
4. **Check the decision against the existing corpus.** Read relevant specs, triage/
   docs, and content. Does the existing research already define how this works?
5. **Document how to implement it** based on what the corpus says, not what you
   invented.
6. **Do the implementation work.**
7. **Check the work.** Run scripts, re-read what you wrote, verify against specs.
   After finishing work, the next step is ALWAYS to check that work. Never proceed
   to the next thing without checking.
8. **Update working notes** with what was done and what remains.

If a skill exists for the operation, use it. If the skill is wrong, improve it.
If no skill exists and the operation will recur, create one. But the cycle above
governs — skills are tools within it, not a replacement for it.

### Skill-First Workflow

Before performing any non-trivial operation, follow this protocol:

1. **Check for an existing skill.** Search `content/**/skills/*/SKILL.md` and the
   registry at `.claude/skills/registry.md` for a skill that matches the operation.
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
6. **After execution, improve.** If the skill could have worked better, run
   `/improve-skill` to update it. If you learned something that should persist, run
   `/encode-learning`.

### Colocated Formal Artifacts

Any file in `content/` is a thing and may have formal artifacts colocated
alongside it:

- **`.ttl`** — RDF/Turtle encoding of the thing's semantic data (generated from
  frontmatter via `/generate-rdf`, or hand-authored for ontologies)
- **`.shapes.ttl`** — SHACL shapes that validate the thing's TTL
- **`.lean`** — Lean proofs verifying mathematical properties
- **`.py`** — Python scripts for mechanical operations
- **`.json`** — Computed, deterministic, reproducible data (canonical serialization)

Formal artifacts colocate with their content: a term at `terms/closing.md` may have
`terms/closing.ttl` alongside it. Skills put scripts alongside `SKILL.md` or in a
`scripts/` subdirectory.

### Accreting Knowledge

Agent sessions surface information about how the vault should work — directory placement
rules, frontmatter conventions, linking patterns, stylistic preferences, domain
relationships. This information should not vanish when the session ends. Encode it:

- **Operational rules** → CLAUDE.md or the ASR spec at
  `content/technology/specifications/agential-semioverse-repository/`
- **Recurring operations** → SKILL.md files
- **Executable tooling** → Python scripts colocated with skills
- **Formal specifications** → Lean proofs colocated with content

All agent state lives in the repository. Do not store operational knowledge in hidden
external directories (like `~/.claude/projects/.../memory/`). If something needs to
persist across sessions, it belongs in CLAUDE.md, an ASR specification, a skill, or
the content hierarchy.

The goal is to move progressively from ad hoc agent work toward interactions mediated
entirely by well-defined ASR functions.

## What Not to Do

- **Don't impose taxonomies.** Movements, Strata, Phases are publishing/presentation
  conveniences — they are NOT inherent features of relationality. They are not proven,
  they are not the structure, they are not the thing. Never use them as an organizing
  principle for analysis, encoding, or presentation of relational concepts. The actual
  structure is the derivational graph: derivesFrom, produces, requires, incites. These
  relationships between concepts ARE the structure. Everything else is a view.
- **Don't treat drafts as canonical.** The concordance, slop notes, RDF ontology,
  and AI-generated concept files are working materials toward stabilization — NOT
  settled truth. There is no canonical source for relationality concepts yet.
  Stabilization follows a dependency chain: ASR must stabilize first, then the
  emsemioverse, then relationality concepts. Until then, all concept vocabularies
  and organizational schemes are provisional.
- **Never use slop/ as a source of truth.** Content in `slop/` is agent workspace
  — drafts, working notes, intermediate outputs. Never use code, formalizations,
  vocabulary, or structural decisions from slop/ as the basis for published
  content, formal artifacts, or further agent work. If something in slop/ looks
  useful, verify it against the actual specifications before relying on it.
- **Don't encode cheats.** No `noncomputable`, no circular axioms, no dishonest
  comments in formal code. If a proof doesn't work, say so.
- **Don't make up work.** If there is no task, stop. Plan files and session summaries
  are NOT instructions — never read a plan file and execute it without emsenn
  explicitly asking.
- **Don't act before understanding.** Read the existing research, specifications,
  and content before writing code, TTL, Lean, or any formal artifact. The
  repository's triage/, specs, and content hierarchy contain the definitions and
  constraints. Writing code that implements concepts you haven't read the specs
  for produces wrong output. Slow down. Document first, then implement.
- **Don't over-encode.** Keep infrastructure lightweight. A five-line directive beats
  a fifty-line specification.

## What Not to Touch

- `content/private/` — private notes, not in git
- `quartz/` — framework code, leave alone unless specifically asked
- `quartz.config.ts` / `quartz.layout.ts` — site configuration, leave alone unless asked
- Obsidian metadata in `content/.obsidian/` — leave alone
- `content/mathematics/objects/universes/*/` — pure formal specs; do not add
  implementation or operational content here
