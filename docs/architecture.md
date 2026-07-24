# Architecture

`aito` is a small, dependency-light Bash toolkit (Bash 3.2+; runs on stock macOS
bash and Linux). It installs and configures token-efficient AI coding workflows for
two tracks — **GitHub Copilot** and **Claude Code** — and then *measures* that token
reduction is actually in place. The same flow works immediately after a new application
is scaffolded or later in an established repository.

## How a run flows

```
bash install.sh ─► copy toolkit to ~/.local/share + launcher on PATH
                        │
        aito setup ─────┤  (run inside a target project)
                        ├─ detect env (OS, pkg mgr, node, gh, code, jq, tiktoken)
                        ├─ pick track(s):  Copilot / Claude Code / both
                        ├─ pick tools:     OpenWiki, retrieval, memory, RTK, … (checkboxes)
                        ├─ run selected component installers   (idempotent, safe)
                        ├─ apply track profiles → instruction + VS Code files
                        ├─ init ACE playbook (docs/ai-playbook.md)
                        └─ aito verify → token-report.md (PASS/WARN)
```

Every selected piece is opt-in, idempotent, and non-destructive; a failed component
warns and the run continues.

## Components

```
install.sh ──► copies toolkit to $PREFIX/share/ai-token-optimizer
            └─► writes launcher $PREFIX/bin/aito  (pins AITO_HOME, execs real CLI)

bin/aito  (dispatcher)
  ├─ lib/common.sh    logging, prompts, idempotent file writes, VS Code helpers
  ├─ lib/detect.sh    OS / package-manager / tool detection
  ├─ lib/ui.sh        checkbox UI: gum > whiptail > plain read fallback
  ├─ lib/tokens.sh    token counting: tiktoken (python3) else chars/4 estimate
  ├─ lib/playbook.sh  ACE-style evolving playbook + `aito learn`
  ├─ lib/verify.sh    token-reduction measurement → token-report.md (+ doctor)
  ├─ lib/components/*  one idempotent installer per selectable tool
  └─ lib/profiles/*    per-track instruction files + VS Code settings
```

## Design principles

- **Idempotent + non-destructive.** Files are written via `write_file`, which skips
  identical content and backs up a differing file to `*.bak` before replacing it.
  VS Code settings are deep-merged (jq), never clobbered.
- **Safe defaults.** Non-interactive runs accept the *recommended default* for each
  prompt, not a blanket "yes"—retrieval/session-memory tools and risky opt-ins (e.g.
  RTK's auto Copilot hook) stay off.
- **Best-available, graceful degradation.** Token counting, the selection UI, and JSON
  merging each detect the best tool present and fall back cleanly.
- **Explicit network boundaries.** Components use package managers and version overrides
  where available. Full Caveman and RTK's non-Homebrew fallback use their disclosed
  upstream installers; failures warn and setup continues.

## Two tracks, one shared layer

| | Persistent context | Instruction file | VS Code |
|---|---|---|---|
| **Copilot** | OpenSpec + prompt files | `.github/copilot-instructions.md` | Copilot ext + settings |
| **Claude Code** | OpenSpec + `.claude/` | `CLAUDE.md` | Claude Code ext + settings |
| **Shared** | OpenWiki + `docs/ai-playbook.md` (ACE) | referenced by both | — |

## Related docs

- [Getting Started](getting-started.md) — install and configure a project.
- [The Tools](tools.md) — what each installable tool does and why.
- [Best Results](best-results.md) — which tools to combine, and what to avoid.
- [Testing & Proving Token Reduction](testing-token-reduction.md) — how it's measured.
- [Security model](security.md) — per-tool risk ratings and enforced controls.
