# CLAUDE.md

Additional instructions for Claude Code agents. **Read `AGENTS.md`
first** — it has the complete operating manual for all agents working
in this repository.

This file adds Claude Code-specific session procedures, skill routing,
and workflow that depend on the `.claude/` infrastructure.

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

## Message handling

In response to every user message, apply the interpret-message skill at
`content/technology/specifications/agential-semioverse-repository/skills/interpret-message/SKILL.md`.
This skill implements the encoding loop — the endeavor's practice of
turning input into encoded meaning: extract meaning from the message,
write texts, refine terms/concepts, identify research questions, then
execute actions. The user's words are the primary input to the
emsemioverse — encode them as content, don't just discuss them.

## Skills and routing

Skills are part of the endeavor's method — codified capabilities at
`SKILL.md` files in `content/`. Registry at `.claude/skills/registry.md`.
Prompts starting with `/` name a skill directly. The ASR theory
documents at
`content/technology/specifications/agential-semioverse-repository/theory/`
formalize prompt routing, skill interaction, and work-unit lifecycle.

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

## Policies

Standing commitments are loaded automatically via
`.claude/rules/policies/`. See
`content/personal/projects/emsemioverse/policies/` for full rationale.
