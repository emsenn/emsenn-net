# AGENTS.md

General instructions for AI agents working in this repository.

## Project

Quartz 4 static site publishing emsenn's research notes from an Obsidian vault.
Live at **emsenn.net**. The `content/` directory is the Obsidian vault and primary
working area.

See `CLAUDE.md` for full project context, including the semioverse hierarchy that
underlies the vault's structure.

## Build

```bash
nvm install --lts    # ensure latest Node LTS is installed
nvm use --lts        # use Node LTS in this shell
npm install          # install dependencies
```

Node version is specified in `.node-version`, but agents should default to `nvm use --lts`.

Do not run `npx quartz build` or `npx quartz sync` unless the user explicitly asks.
Site builds are intentionally avoided during normal agent work because they are slow.

## Content Layout

Fixed special directories:

| Directory              | Purpose                          | Published |
| ---------------------- | -------------------------------- | --------- |
| `content/general`      | Cross-disciplinary reference     | yes       |
| `content/personal`     | Personal writing                 | yes       |
| `content/writing`      | Writing discipline (style, etc.) | yes       |
| `content/assets`       | Images and binary files          | yes       |
| `content/slop`         | AI working area — drafts         | no        |
| `content/triage`       | Unprocessed inbox content        | no        |
| `content/meta`         | Obsidian templates               | no        |
| `content/private`      | Private notes (also gitignored)  | no        |

Discipline modules (`cosmology/`, `ecology/`, `linguistics/`, `mathematics/`,
`philosophy/`, `sociology/`, `technology/`, etc.) live directly at the `content/`
root — there is no `study/` directory. Use `find content -mindepth 1 -maxdepth 2 -type d`
to discover the current set.

Each discipline follows a standard internal structure (`disciplines/`, `topics/`,
`schools/`, `texts/`, `terms/`, `concepts/`, `curricula/`, `history/`). Full spec at
`content/technology/specifications/agential-semioverse-repository/directory-organization/`.

## Frontmatter Schema

```yaml
title: string
date-created: ISO 8601 datetime
```

## File Handling

Large binary files are managed with Git LFS. Tracked types: `pdf`, `epub`, `docx`,
`odt`, `png`, `jpg`, `jpeg`, `gif`, `webp`, `tiff`, `stl`, `3mf`, `obj`, `gcode`,
`mp3`, `mp4`, `wav`, `ogg`.

## Conventions

- Work directly on `main` — do not create worktrees or branches unless explicitly asked
- emsenn edits the vault concurrently in Obsidian; run `git status` before staging
- Markdown files use LF line endings (enforced by `.gitattributes`)
- Internal links use relative-path markdown syntax: `[Display Text](relative/path.md)`. Agents must NEVER generate wikilinks (`[[...]]`) — those are placeholders for emsenn only.
- `content/private/` is gitignored — do not stage or reference those files
- Agent-generated drafts belong in `content/slop/`
- Do not place loose `.md` files at a discipline root; use the appropriate subdirectory
