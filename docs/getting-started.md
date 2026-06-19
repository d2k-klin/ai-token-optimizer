# Getting Started

`aito` is a small CLI that configures **token-efficient AI coding workflows** for
GitHub Copilot and Claude Code, then measures that the reduction is real. This guide
takes you from zero to a configured project.

> New here? Read the one-paragraph idea in the [project README](../README.md), then
> come back. For *what each tool does* see [tools.md](tools.md); for *how reduction is
> proven* see [testing-token-reduction.md](testing-token-reduction.md).

## 1. Prerequisites

| Required | Why |
|---|---|
| **Bash 3.2+** | The CLI itself (works with stock macOS bash). |
| **git** | Detect the repo, back up files safely. |

| Recommended | Enables |
|---|---|
| **Node.js + npm** | Installing OpenSpec, RTK, Repomix, Codesight, Graphify. |
| **jq** | Deep-merging VS Code `settings.json` instead of printing keys to add. |
| **python3 + `tiktoken`** | Exact token counts (otherwise a labeled chars/4 estimate). |
| **VS Code `code` CLI** | Auto-installing the Copilot / Claude Code extensions. |
| **`gum` or `whiptail`** | A nicer checkbox UI (a plain text UI is the fallback). |

Nothing in the recommended list is mandatory — `aito` degrades gracefully and tells you
what it skipped.

## 2. Install the CLI

```bash
git clone https://github.com/d2k-klin/ai-token-optimizer.git
cd ai-token-optimizer
make install                         # installs `aito` to ~/.local/bin
# make install PREFIX=/usr/local     # system-wide (may prompt for sudo)
# (no make? use: bash install.sh)
```

The installer copies the toolkit to `~/.local/share/ai-token-optimizer` and writes a
`aito` launcher to `~/.local/bin`. If that directory is not on your `PATH`, it prints
the exact line to add to `~/.zshrc` or `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Verify:

```bash
aito version
aito env        # shows detected OS, package manager, and tools
```

## 3. Configure a project

From the **root of the project** you want to optimize:

```bash
aito setup
```

You'll be asked two things:

1. **Track(s)** — GitHub Copilot, Claude Code, or both.
2. **Tools** — OpenSpec, RTK, ccusage, Caveman, Codesight, Graphify, Repomix, gh-aw. The
   recommended ones (OpenSpec + concise instructions + RTK + ccusage) are pre-checked; the
   optional repo-mappers and automation are off by default.

In the plain UI: type a number to toggle it, `a` for all, `n` for none, then **Enter**
to confirm.

`aito` then installs the selected tools, writes the instruction/config files, and
finishes by running `aito verify` so you immediately see whether reduction is in place.

### Non-interactive (CI / scripted)

```bash
AITO_ASSUME_YES=1 aito setup
```

This accepts the **recommended defaults** for every prompt — notably, risky opt-ins such
as RTK's automatic Copilot hook stay **off**. Use `AITO_UI=plain` to force the text UI.

## 4. What gets written

| Track | Files |
|---|---|
| Copilot | `.github/copilot-instructions.md`, `.github/instructions/openspec.instructions.md`, `.vscode/settings.json` |
| Claude Code | `CLAUDE.md`, `.claude/settings.json`, `.vscode/settings.json` |
| Shared | `openspec/config.yaml`, `docs/ai-playbook.md`, `token-report.md` |

Existing files are never clobbered: a differing file is backed up to `*.bak` first, and
VS Code settings are deep-merged. Re-running `aito setup` is safe and idempotent.

Review the generated files, then commit them.

## 5. Everyday commands

```bash
aito verify    # (re)measure token reduction → token-report.md
aito doctor    # check config files, token budgets, and tool availability
aito learn "Prefer rtk tsc before committing"   # add a lesson to the playbook
aito env       # show detected environment
aito help      # full command + env-var reference
```

## 6. Update or remove

```bash
# update: pull the repo, then re-run the installer
git -C /path/to/ai-token-optimizer pull && bash /path/to/ai-token-optimizer/install.sh

# uninstall the CLI (your per-project config files are left untouched)
bash /path/to/ai-token-optimizer/install.sh --uninstall
```

## Next steps

- [Understand each tool →](tools.md)
- [Combine tools for best results →](best-results.md)
- [Prove the reduction →](testing-token-reduction.md)
- [See how it all fits together →](architecture.md)
- [Review the security model →](security.md)
