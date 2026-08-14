# aito — stop your AI coding agent from burning tokens

[![CI](https://github.com/d2k-klin/ai-token-optimizer/actions/workflows/ci.yml/badge.svg)](https://github.com/d2k-klin/ai-token-optimizer/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![shellcheck](https://img.shields.io/badge/shellcheck-clean-brightgreen.svg)](.github/workflows/ci.yml)
[![bash 3.2+](https://img.shields.io/badge/bash-3.2%2B-green.svg)](#)
[![aito telemetry: none](https://img.shields.io/badge/aito_telemetry-none-1f6feb.svg)](#privacy--safety)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/d2k-klin/ai-token-optimizer/pulls)

GitHub Copilot and Claude Code waste tokens re-reading your repo, dumping build logs into
context, and rebuilding the same explanations every session. **`aito` sets up a
token-efficient workflow in one command — then measures the savings so you don't have to
take a number on faith.**

Use it to **jump-start a new project** with AI instructions, persistent context, sensible
tool defaults, and measurement from the first commit—or add the same workflow safely to
an established repository. `aito` configures the AI-development layer; your normal
framework or project generator still creates the application itself.

It doesn't reinvent anything — it's a **summarized setup of the available tools for token
optimization during development**: a curated set (OpenWiki, Serena, OpenSpec, RTK,
ccusage, and more) wired together behind an interactive menu with safe defaults. It lays
down concise instruction files for each assistant and writes a `token-report.md` you can
actually read.

```bash
git clone https://github.com/d2k-klin/ai-token-optimizer.git
cd ai-token-optimizer && make install      # ~30s, no curl|bash
aito setup                                  # pick tools, get a measured report
```

<!-- DEMO: replace this block with an asciinema/GIF of `aito setup` → `aito verify`.
     Record with:  asciinema rec demo.cast   (or)   vhs demo.tape
     Embed:        [![asciicast](https://asciinema.org/a/XXXXX.svg)](https://asciinema.org/a/XXXXX) -->
> 🎬 **Demo:** _(coming — a 15-second `aito setup → verify` recording goes here)_

## Why it's different

- **It measures, it doesn't promise.** No invented "saves 70%!" headline — `aito verify`
  reports real token counts and a PASS/WARN verdict you can reproduce.
- **Retrieval before compression.** Serena, Codebase-Memory-MCP, QMD, and grepai can
  retrieve a symbol, relationship, or document instead of loading whole files first.
- **No telemetry or proxy in `aito` itself.** It runs offline except the component
  installs you explicitly choose. Headroom is opt-in and off by default; third-party
  telemetry is called out below. See [Privacy & safety](#privacy--safety).
- **Two tracks:** GitHub Copilot and Claude Code in VS Code — pick one or both.
- **New or existing projects:** establish the workflow at project creation, or layer it
  onto a mature repository without silently replacing existing configuration.
- **Safe by construction:** idempotent, never clobbers files (backs up + deep-merges),
  risky options off by default, `shellcheck`-clean with a mocked offline test suite.
- **Cross-platform:** macOS / Linux, Bash 3.2+ (works with stock macOS bash).

## Tools considered

Selectable tools and documented complements are listed below. See
[The Tools](docs/tools.md) for the full rundown and
[Best Results](docs/best-results.md) for how to combine them.

| Tool | What it does | In `aito` |
|---|---|---|
| [Caveman](https://github.com/JuliusBrussee/caveman) | Adds concise-output instructions to cut response verbosity (a lite version is always applied). | Default |
| [Ponytail](https://ponytail.dev) | Ruleset plugin that makes the agent write the least code that works (reuse → stdlib → platform → deps → custom). | Default |
| [OpenWiki](https://github.com/langchain-ai/openwiki) | Generates and maintains local codebase documentation for coding agents; optional scheduled PR updates. | Default |
| [OpenSpec](https://github.com/Fission-AI/OpenSpec) | Persistent spec / requirements / design / tasks layer that keeps requirements stable across sessions. | Optional |
| [Serena](https://github.com/oraios/serena) | Retrieves and edits precise code symbols and references through language servers. | Optional |
| [Codebase-Memory-MCP](https://github.com/DeusData/codebase-memory-mcp) | Builds a local structural code graph for fast relationship and impact queries. | Optional |
| [QMD](https://github.com/tobi/qmd) | Runs local BM25 + vector + reranked search over OpenWiki, OpenSpec, and other Markdown. | Optional |
| [grepai](https://github.com/yoanbernabeu/grepai) | Provides semantic code search and call graphs with local or cloud embeddings. | Optional |
| [Claude-Mem](https://github.com/thedotmack/claude-mem) | Compresses and retrieves agent observations across Claude Code sessions. | Optional (warned) |
| [RTK](https://github.com/rtk-ai/rtk) | Compresses noisy terminal output (git, tests, builds, logs) before it enters model context. | Optional |
| [ccusage](https://github.com/ccusage/ccusage) | Local CLI that reports token usage and cost from your agent logs so you can watch the trend. | Optional |
| [Codesight](https://github.com/Houseofmvps/codesight) | Generates a compact AST-based repo map / wiki so the agent re-reads fewer files. | Optional |
| [Graphify](https://github.com/rhanka/graphify) | Maps code plus docs into a knowledge graph for relationship and architecture questions. | Optional |
| [Repomix](https://github.com/yamadashy/repomix) | Packs the repo into one AI-friendly file with token counts, for one-off exports. | Optional |
| [gh-aw](https://github.com/github/gh-aw) | Compiles natural-language workflows into GitHub Actions that run AI agents on events. | Optional |
| [Headroom](https://github.com/chopratejas/headroom) | Local proxy that compresses context before it reaches the model. | Opt-in (off, warned) |
| [Context7](https://github.com/upstash/context7) | Fetches current, targeted library/API documentation on demand. | Documented |
| [code2prompt](https://github.com/mufeedvh/code2prompt) | Packs a codebase into a single prompt with token counts and filtering (Repomix alternative). | Documented |
| [LLMLingua](https://github.com/microsoft/LLMLingua) | Compresses prompts up to ~20× by dropping low-information tokens (advanced, for custom pipelines). | Documented |

The layers are intentionally different:

```text
don't generate it  → Caveman / Ponytail
don't retrieve it  → Serena / Codebase-Memory-MCP / QMD / grepai
don't rediscover it → OpenWiki / OpenSpec / Claude-Mem / ACE playbook
compress when needed → RTK / Headroom / LLMLingua
measure the result  → aito verify / ccusage
```

## Privacy & safety

This is deliberately boring, which is the point:

- **No network from `aito` itself** except the component installs you pick (npm, PyPI,
  GitHub releases/plugin marketplaces, or an explicitly confirmed upstream installer).
- **No `aito` telemetry.** Third-party policies still apply. OpenSpec and OpenWiki have
  telemetry enabled upstream; `aito` disables it when it invokes either tool. For manual
  use, set `OPENSPEC_TELEMETRY=0` or `OPENWIKI_TELEMETRY_DISABLED=1` (or
  `DO_NOT_TRACK=1`). Serena's startup metrics use
  `SERENA_USAGE_REPORTING=false`.
- **Memory/retrieval stays opt-in.** Claude-Mem persists session observations;
  Codebase-Memory, QMD, and grepai create local indexes; cloud grepai embeddings and
  Context7 queries cross the network. Review the [security model](docs/security.md).
- **No proxy by default.** The only proxy-based tool (Headroom) is strictly opt-in, off by
  default, and flagged with a warning before install — nothing intercepts your AI traffic
  unless you explicitly choose it.
- **Non-destructive:** existing files are backed up to `*.bak`; VS Code settings are merged.
- **Auditable bootstrap:** clone the repo and run its local installer. The optional full
  Caveman install and RTK's non-Homebrew fallback invoke their disclosed upstream
  installers only when selected.

## Documentation

| Guide | What's inside |
|---|---|
| **[Getting Started](docs/getting-started.md)** | Prerequisites plus fresh-project and existing-project setup. |
| **[The Tools](docs/tools.md)** | What each available tool does and why it saves tokens. |
| **[Best Results](docs/best-results.md)** | Which tools to combine, recipes, and what to avoid. |
| **[Testing & Proving Token Reduction](docs/testing-token-reduction.md)** | How `aito verify` measures it and how to read the report. |
| **[Architecture](docs/architecture.md)** | How the CLI is structured and how a run flows. |
| **[Security model](docs/security.md)** | Per-tool risk ratings and the controls enforced. |

New here? Start with [Getting Started](docs/getting-started.md).

## Install

```bash
git clone https://github.com/d2k-klin/ai-token-optimizer.git
cd ai-token-optimizer
make install                    # installs `aito` to ~/.local/bin
# make install PREFIX=/usr/local   # system-wide (may prompt for sudo)
```

Prefer not to use `make`? `bash install.sh` does the same thing
(`PREFIX=/usr/local bash install.sh` for system-wide).

Add `~/.local/bin` to your `PATH` if the installer says so. Uninstall with
`make uninstall` (or `bash install.sh --uninstall`).

## Use

### Jump-start a new project

Create the application with your usual framework or project generator, then establish
the AI workflow before the first AI-assisted task:

```bash
cd my-new-project
git init       # skip if the project generator already did this
aito setup
```

This gives the project concise assistant instructions, a durable playbook, selected
tools, and a token-reduction baseline from the start. Initialize OpenWiki after the
project has enough source code to document.

### Add it to an existing project

Run from the repository root:

```bash
aito setup     # pick track(s) + tools via checkboxes, then auto-verify
aito verify    # (re)measure token reduction → token-report.md
aito doctor    # check config files, token budgets, and tools
aito learn "Run rtk tsc before committing"   # add a lesson to the playbook
aito env       # show detected environment
```

Non-interactive (CI or scripted): `AITO_ASSUME_YES=1 aito setup` picks the recommended
defaults (Caveman + Ponytail + OpenWiki; everything else, including OpenSpec, RTK, and
ccusage, stays off). The optional OpenWiki documentation-update workflow also stays off.

## What it writes

| Track | Files |
|---|---|
| Copilot | `.github/copilot-instructions.md`, `.github/instructions/openspec.instructions.md`, `.vscode/settings.json` |
| Claude Code | `CLAUDE.md`, `.claude/settings.json`, `.vscode/settings.json` |
| Shared | `openspec/config.yaml`, `docs/ai-playbook.md` (ACE), `token-report.md` |

Existing files are backed up to `*.bak`; VS Code settings are deep-merged.
OpenWiki itself writes `openwiki/` plus managed sections in `AGENTS.md` and `CLAUDE.md`
only after you run `openwiki --init`. If you approve the separate setup prompt, `aito`
also adds `.github/workflows/openwiki-update.yml`.

## How reduction is measured

`aito verify` writes `token-report.md` with four gates: instruction conciseness,
RTK raw-vs-compressed command output, targeted-vs-whole-repo context, and persistent
artifact footprint — closed by a PASS/WARN verdict. Uses `tiktoken` when available, else
a labeled chars/4 estimate. See [Testing & Proving Token Reduction](docs/testing-token-reduction.md).

## Configuration (env vars)

| Var | Effect |
|---|---|
| `AITO_ASSUME_YES=1` | Non-interactive; accept recommended defaults |
| `AITO_UI=plain` | Force the plain (read-based) selection UI |
| `AITO_INSTRUCTION_BUDGET=1500` | Token budget for instruction files |
| `AITO_OPENWIKI_VERSION` / `AITO_OPENSPEC_VERSION` / `AITO_CCUSAGE_VERSION` | Pin npm component versions |
| `AITO_SERENA_VERSION` / `AITO_CLAUDE_MEM_VERSION` | Pin Serena or Claude-Mem |
| `AITO_CODEBASE_MEMORY_VERSION` / `AITO_QMD_VERSION` / `AITO_GREPAI_VERSION` | Pin retrieval components (grepai pin applies to Go builds) |
| `AITO_RTK_VERSION` | Pin the RTK release installed by its verified upstream installer |
| `AITO_CODESIGHT_VERSION` / `AITO_GRAPHIFY_VERSION` / `AITO_REPOMIX_VERSION` | Pin repository-tool versions |
| `AITO_HEADROOM_VERSION` | Pin the Headroom Python package version |
| `NO_COLOR=1` | Disable colored output |

## Development & testing

```bash
make test     # shellcheck + bats (full local suite); skips a tool if not installed
make lint     # shellcheck only
make unit     # bats only
```

Prereqs: `shellcheck` and `bats` (`brew install shellcheck bats-core` or
`apt-get install shellcheck bats`). The bats suite mocks all external tools, so it runs
offline and installs nothing. To try it by hand, run `AITO_ASSUME_YES=1 aito setup`
inside a throwaway `git init` directory.

MIT licensed.
