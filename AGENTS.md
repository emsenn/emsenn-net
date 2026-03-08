# AGENTS.md

Instructions for AI agents working in this repository.

## Project

Quartz 4 static site publishing emsenn's research from an Obsidian vault.
Live at **emsenn.net**. The `content/` directory is the vault and primary
working area. See `CLAUDE.md` for full project context.

## Build

```bash
nvm install --lts && nvm use --lts && npm install
```

Do not run `npx quartz build` unless explicitly asked — builds are slow.

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

Discipline modules (`mathematics/`, `philosophy/`, `technology/`, etc.) live
at `content/` root. Each follows a standard structure: `disciplines/`,
`topics/`, `schools/`, `texts/`, `terms/`, `concepts/`, `curricula/`,
`history/`. Full spec at
`content/technology/specifications/agential-semioverse-repository/directory-organization/`.

## Conventions

- Use relative-path markdown links: `[text](relative/path.md)`. Never
  generate wikilinks (`[[...]]`).
- Minimum frontmatter: `title:` and `date-created:` (ISO 8601)
- Work on `main` unless told otherwise
- Check `git status` before staging (emsenn edits concurrently)
- Large binaries tracked with Git LFS
- `content/private/` is gitignored — never stage
- Agent drafts go in `content/slop/`
- No loose `.md` files at discipline roots
