# Changelog

All notable changes to `aito` and the upstream tools it installs.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Unpinned package installs default to the current release; the table below records the
versions whose commands and compatibility were validated together.

## [Unreleased]

## [1.0.0] — 2026-07-24

### Tool versions refreshed

| Tool | Latest | Released | Install path | Compatibility result |
|---|---:|---:|---|---|
| OpenWiki | `0.2.3` | 2026-07-23 | `openwiki` (npm) | Added as a default; requires Node 22+ |
| OpenSpec | `1.6.0` | 2026-07-10 | `@fission-ai/openspec` (npm) | `init --tools` still valid; now requires Node 20.19+ |
| Serena | `1.6.1` | 2026-07-21 | `serena-agent` (PyPI/uv) | Added as optional symbol retrieval; Python 3.11–3.14 |
| Codebase-Memory-MCP | `0.9.0` | 2026-07-08 | npm/native binary | Added as optional structural retrieval; Node 18+ wrapper |
| QMD | `2.5.3` | 2026-05-29 | `@tobilu/qmd` (npm) | Added as optional local doc retrieval; Node 22+ |
| grepai | `0.35.0` | 2026-03-16 | Homebrew / pinned Go build | Added as optional semantic code retrieval |
| Claude-Mem | `13.12.4` | 2026-07-24 | official `npx ... install` | Added as opt-in session memory; Node 20.12+ |
| Context7 CLI | `0.5.5` | 2026-07-17 | `ctx7` (npm, documented only) | Complementary remote library-doc retrieval |
| RTK | `0.43.0` | 2026-06-28 | Homebrew / verified upstream installer | Commands unchanged |
| ccusage | `20.0.18` | 2026-07-20 | `ccusage` (npm) | Commands unchanged |
| Caveman | `1.9.1` | 2026-07-03 | official installer | Node 18+; commands unchanged |
| Ponytail | `4.8.4` | 2026-06-29 | plugin marketplace | Claude/Copilot commands unchanged |
| Codesight | `1.18.0` | 2026-06-28 | `codesight` (npx) | `--wiki` unchanged; Node 18+ |
| Graphify | `0.17.1` | 2026-06-23 | `@sentropic/graphify` (npm) | **Install/use flow changed; adjusted below** |
| Repomix | `1.17.0` | 2026-07-21 | `repomix` (npx) | Commands unchanged; now requires Node 22+ |
| gh-aw | `0.83.1` | 2026-07-23 | `github/gh-aw` (gh extension) | Install command unchanged |
| Headroom | `0.32.1` | 2026-07-19 | `headroom-ai[proxy]` (PyPI) | **Package extras/integrations changed; adjusted below** |
| code2prompt | `4.2.0` | 2025-12-11 | Homebrew / Cargo (documented only) | Removed incorrect npm command |
| LLMLingua | `0.2.2` | 2024-04-09 | `llmlingua` (pip, documented only) | No change |

### Required compatibility changes

- **Retrieval layer:** added Serena, Codebase-Memory-MCP, QMD, and grepai as optional
  retrieval-before-compression components. Serena/Codebase-Memory/grepai are alternatives;
  QMD can coexist because it targets Markdown knowledge.
- **Claude-Mem 13.12.4:** uses the official `npx claude-mem@<version> install` path
  because a global npm install is only the SDK. Session capture, hooks, and its worker
  remain off by default and behind an extra privacy confirmation.
- **Context7 0.5.5:** documented as a complementary remote source for current library/API
  documentation, not as an installed token-optimizer component.
- **OpenWiki 0.2.3:** added the Node 22+ global CLI as a default component. Initial
  provider/model setup remains user-driven because `openwiki --init` is interactive.
  Setup separately asks whether to add the official scheduled documentation-update
  pattern; the bundled workflow defaults telemetry off and pins its CLI/actions.
- **Graphify 0.17.1:** replaced the obsolete bare
  `npx @sentropic/graphify` invocation with the supported global npm install plus
  `graphify install --platform ...`. `aito` now installs the Claude Code and/or VS Code
  Copilot skill selected by the active tracks. Current output lives under `.graphify/`,
  which is ignored along with the legacy `graphify-out/` directory. Graph creation is
  now invoked from the agent with `/graphify .`.
- **Headroom 0.32.1:** updated the repository to `headroomlabs-ai/headroom`, installed
  the required `headroom-ai[proxy]` extra, preferred Python 3.13 when available, and
  removed the obsolete Copilot-only description. Python 3.10+ remains the hard minimum.
- **OpenSpec 1.6.0:** added the Node 20.19 runtime guard and disabled its anonymous
  command/version telemetry during `aito` initialization. Users should export
  `OPENSPEC_TELEMETRY=0` or `DO_NOT_TRACK=1` for later OpenSpec commands.
- **Repomix 1.17.0:** added the Node 22 runtime guard.
- **RTK:** removed documentation that installed the unrelated npm package named `rtk`.
  The supported Homebrew/official-binary path remains unchanged, and
  `AITO_RTK_VERSION` now maps to the upstream installer's version pin.
- **code2prompt:** replaced the unrelated `npx code2prompt` package with the official
  Rust CLI installation commands (`brew install code2prompt` or
  `cargo install code2prompt`).

### Changed in `aito`

- Added reusable Node semantic-version checks and explicit runtime errors for OpenWiki,
  OpenSpec, Claude-Mem, Codebase-Memory-MCP, QMD, Codesight, Graphify, and Repomix.
- Added version overrides for the new retrieval/session-memory components, Codesight,
  Graphify, Repomix, and Headroom; existing OpenSpec and ccusage installs are now updated
  when those components are selected.
- Corrected stale ccusage, Graphify, and Headroom repository links.
- Scoped the telemetry claim to `aito` itself and documented third-party network and
  telemetry behavior accurately.
- Documented `aito` as both a new-project AI-workflow jump start and a safe addition to
  established repositories, without presenting it as an application scaffolder.
