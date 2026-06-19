# aito — stop your AI coding agent from burning tokens

[![CI](https://github.com/d2k-klin/ai-token-optimizer/actions/workflows/ci.yml/badge.svg)](https://github.com/d2k-klin/ai-token-optimizer/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![shellcheck](https://img.shields.io/badge/shellcheck-clean-brightgreen.svg)](.github/workflows/ci.yml)
[![bash 3.2+](https://img.shields.io/badge/bash-3.2%2B-green.svg)](#)
[![telemetry: none](https://img.shields.io/badge/telemetry-none-1f6feb.svg)](#privacy--safety)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/d2k-klin/ai-token-optimizer/pulls)

GitHub Copilot and Claude Code waste tokens re-reading your repo, dumping build logs into
context, and rebuilding the same explanations every session. **`aito` sets up a
token-efficient workflow in one command — then measures the savings so you don't have to
take a number on faith.**

It doesn't reinvent anything — it's a **summarized setup of the available tools for token
optimization during development**: a curated set (OpenSpec, RTK, ccusage, and more) wired
together behind an interactive menu with safe defaults. It lays down concise instruction
files for each assistant and writes a `token-report.md` you can actually read.

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
- **No `curl | bash`. No telemetry. No proxy by default.** Runs offline except the tool
  installs you explicitly choose; reads nothing it doesn't show you. (The one proxy-based
  tool, Headroom, is opt-in and off by default.) See [Privacy & safety](#privacy--safety).
- **Two tracks:** GitHub Copilot and Claude Code in VS Code — pick one or both.
- **Safe by construction:** idempotent, never clobbers files (backs up + deep-merges),
  risky options off by default, `shellcheck`-clean with a mocked offline test suite.
- **Cross-platform:** macOS / Linux, Bash 3.2+ (works with stock macOS bash).

## Privacy & safety

This is deliberately boring, which is the point:

- **No network** except the component installs you pick (npm/pip), each version-pinnable.
- **No telemetry, no analytics, no phone-home.** Ever.
- **No proxy by default.** The only proxy-based tool (Headroom) is strictly opt-in, off by
  default, and flagged with a warning before install — nothing intercepts your AI traffic
  unless you explicitly choose it.
- **Non-destructive:** existing files are backed up to `*.bak`; VS Code settings are merged.
- **Auditable install:** clone the repo and read it — no piped shell scripts.

## Documentation

| Guide | What's inside |
|---|---|
| **[Getting Started](docs/getting-started.md)** | Prerequisites, install, and a first-run walkthrough. |
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

Run inside any project:

```bash
aito setup     # pick track(s) + tools via checkboxes, then auto-verify
aito verify    # (re)measure token reduction → token-report.md
aito doctor    # check config files, token budgets, and tools
aito learn "Run rtk tsc before committing"   # add a lesson to the playbook
aito env       # show detected environment
```

Non-interactive (CI or scripted): `AITO_ASSUME_YES=1 aito setup` picks the recommended
defaults (OpenSpec + concise instructions + RTK; optional mappers off).

## What it writes

| Track | Files |
|---|---|
| Copilot | `.github/copilot-instructions.md`, `.github/instructions/openspec.instructions.md`, `.vscode/settings.json` |
| Claude Code | `CLAUDE.md`, `.claude/settings.json`, `.vscode/settings.json` |
| Shared | `openspec/config.yaml`, `docs/ai-playbook.md` (ACE), `token-report.md` |

Existing files are backed up to `*.bak`; VS Code settings are deep-merged.

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
| `AITO_OPENSPEC_VERSION` / `AITO_RTK_VERSION` | Pin component versions |
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
