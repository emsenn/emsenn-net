# emsenn.net

The **emsemioverse** — a semiotic endeavor conducted by emsenn, a Lakota
land steward and independent researcher. Published at
[emsenn.net](https://emsenn.net).

The central concern is **relationality**: a philosophical-mathematical
framework treating relations as ontologically prior to entities. The
repository holds research across mathematics, philosophy, technology,
ecology, linguistics, and other disciplines.

## Structure

- `content/` — Obsidian vault containing all research content. Tracked
  as a [separate repository](https://github.com/emsenn/content).
- `quartz/` — [Quartz v4](https://quartz.jzhao.xyz/) static site
  framework (by [jackyzha0](https://github.com/jackyzha0/quartz)).
- `scripts/` — Python and shell utilities for content management.
- `quartz.config.ts` / `quartz.layout.ts` — site configuration.

The content vault is organized into discipline modules at `content/`
root (`mathematics/`, `philosophy/`, `technology/`, `ecology/`, etc.),
each following a standard structure of `terms/`, `concepts/`, `texts/`,
`curricula/`, and more. The organizing conventions are specified at
`content/technology/specifications/`.

## Build

```bash
nvm install --lts && nvm use --lts && npm install
npx quartz build --serve
```

## License

The Quartz framework code and site configuration are MIT-licensed (see
`LICENSE.txt`). The `content/` directory is a separate repository and
may be subject to different terms.

## For AI agents

See `AGENTS.md` for the complete operating manual. Claude Code agents
should also read `CLAUDE.md` for additional session procedures.
