# ai-token-optimizer (`aito`)

A globally-installable CLI that provides a **summarized setup of available tools for
token optimization during development**. It configures **token-efficient AI coding
workflows** for **GitHub Copilot** and **Claude Code** in VS Code — then *proves* the
token reduction with a measured before/after report.

Rather than reinventing anything, `aito` installs, configures, and wires together
existing tools behind an interactive menu, with safe defaults. It turns the
"Token-Efficient Feature Delivery" concept (OpenSpec + concise instruction files + RTK,
with Codesight/Graphify/Repomix/gh-aw as opt-ins) into a one-command setup, and folds in
techniques from **ACE** (evolving context playbooks), **Pochi** (compaction, MCP scoping,
delegating bulk data to code), and Claude token-optimization guidance (prompt caching,
model selection, batching).

- **Cross-platform:** macOS / Linux, Bash 3.2+ (works with stock macOS bash).
- **Two tracks:** GitHub Copilot and Claude Code — pick one or both.
- **Selectable tools:** OpenSpec, RTK, ccusage, Caveman, Codesight, Graphify, Repomix, gh-aw.
- **Safe:** idempotent, never clobbers files, risky options off by default.

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
