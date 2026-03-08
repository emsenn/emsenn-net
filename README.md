# emsenn.net

The **emsemioverse** — a semiotic endeavor conducted by emsenn, a Lakota
land steward and independent researcher. Published at
[emsenn.net](https://emsenn.net).

The central concern is **relationality**: a philosophical-mathematical
framework treating relations as ontologically prior to entities. The
repository holds research across mathematics, philosophy, technology,
ecology, linguistics, and other disciplines.

## Prerequisites

**Required** (site build):
- Node.js (LTS, managed via nvm)
- Python 3.10+

**Optional** (local inference):
- [Ollama](https://ollama.com/) — CPU-based LLM inference (GGUF models)
- [Foundry Local](https://github.com/microsoft/Foundry) — NPU-accelerated
  inference (ONNX models, Snapdragon X / Intel NPU)

Run `python scripts/check-environment.py` to see what is available.

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

## Scripts

| Script | Purpose |
|--------|---------|
| `check-environment.py` | Report available tools and backends (no side effects) |
| `local_llm.py` | Shared client for Ollama + Foundry Local (imported by other scripts) |
| `mcp-server.py` | MCP server exposing repository tools to Claude Code |
| `infer-triage-frontmatter.py` | Enrich triage file frontmatter via local LLM |
| `mine-triage-relevance.py` | Pre-classify triage files by relevance to a focus |
| `extract-formal-definitions.py` | Extract formal definitions from triage files |
| `enrich-triage.py` | Mechanical frontmatter fixes (title, dates, deprecated fields) |
| `index-triage.py` | Build/rebuild the triage index |

All inference scripts use `local_llm.py`, which auto-detects available
backends. When both Ollama and Foundry are available, Foundry (NPU) is
preferred for models it supports. Set `LLM_DISABLED=1` to skip all
local inference. Set `LLM_BACKEND=ollama` or `LLM_BACKEND=foundry` to
force a specific backend.

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
