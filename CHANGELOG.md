# Changelog

All notable changes to `aito` and the upstream tools it installs.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
`aito` always installs the **latest** released version of each tool (via `npm`/`npx`,
the tool's official installer, or a `gh` extension), so the versions below are the
latest validated at the time of writing — pin any of them with the matching
`AITO_*_VERSION` override where supported.

## [Unreleased] — 2026-06-30

### Tool versions refreshed

Verified the latest released version of every bundled tool and confirmed each install
path still works. No `aito` install/setup commands needed to change. Two notes added in
code: ccusage's GitHub org move, and OpenSpec's opt-in Stores beta.

| Tool | Latest | Released | Install path | Action needed |
|---|---|---|---|---|
| OpenSpec | `1.5.0` | 2026-06-28 | `@fission-ai/openspec` (npm) | None — `init --tools` unchanged |
| RTK | `0.43.0` | 2026-06-28 | brew / `install.sh` (Rust binary) | None |
| ccusage | `20.0.14` | 2026-06-15 | `ccusage` (npm) | None — repo URL updated |
| Caveman | `1.9.0` | 2026-06-12 | official `install.sh` | None |
| Ponytail | `4.8.4` | 2026-06-29 | plugin marketplace (`DietrichGebert/ponytail`) | **New** — added as optional component |
| Codesight | `1.18.0` | 2026-06-28 | `codesight` (npx) | None |
| Graphify | `0.17.1` | 2026-06-23 | `@sentropic/graphify` (npx) | None |
| Repomix | `1.16.0` | 2026-06-29 | `repomix` (npx) | None |
| gh-aw | `0.81.6` | 2026-06-27 | `github/gh-aw` (gh ext) | None |
| Headroom | `0.28.0` | 2026-06-29 | `headroom-ai` (pip/pipx) | None — opt-in, off by default |
| code2prompt | `4.2.0` | 2025-12-11 | cargo / npm (documented only) | None |
| LLMLingua | `0.2.2` | 2024-04-09 | `llmlingua` (pip, documented only) | None |

### Per-tool notes

**OpenSpec 1.5.0** — Persistent spec/requirements/tasks layer (default tool).
- New: **Stores** (very early beta) — a simpler spec/change layout meant to replace the
  workspace/initiative model. **Opt-in**; upstream warns of breaking changes while it
  stabilizes. `aito`'s default `openspec init --tools "github-copilot,claude"` flow is
  unaffected (flag and tool IDs verified present in 1.5.0).
- Fixed: config values wrapped in JSON containers now parse correctly; carriage returns
  in generated command descriptions are escaped instead of corrupting CRLF values.
- ⚠️ Action: none. Stay on the default flow; avoid Stores until it's stable.

**RTK 0.43.0** — Compresses noisy terminal output before it enters context (default tool).
- New: OpenShift CLI (`oc`) support with shared k8s filtering; Pulumi filters for
  preview/up/destroy/refresh/stack.
- Fixed: "never-worse output" guard (compressed output can no longer be larger than raw);
  diff now reports modified-only diffs and follows the diff exit-code convention; dotnet
  test de-duplication; git status exit-code propagation in the compact path.
- ⚠️ Action: none. brew/`install.sh` path unchanged.

**ccusage 20.0.14** — Local token-usage & cost monitor (default tool).
- Changed: the project **moved GitHub orgs** from `ryoppippi/ccusage` to `ccusage/ccusage`
  (npm package name `ccusage` is unchanged). Code comment/URL updated accordingly.
- Performance: unified JSONL prefilter/byte-lines across agents; parallelized file/DB
  reads across all agent loaders.
- ⚠️ Action: none. `npm i -g ccusage` is unchanged; the old repo URL still redirects.

**Caveman 1.9.0** — Concise-output instructions (optional; lite version always applied).
- Installed only on explicit opt-in via the official `install.sh`. No interface change.
- ⚠️ Action: none.

**Ponytail 4.8.4** — Minimal-code ruleset plugin (optional, **new in this release**).
- Makes the agent write the least code that works (necessity → reuse → stdlib →
  platform → deps → custom). Installs as a host plugin into Claude Code and Copilot CLI
  via their plugin marketplaces; no npm global, so no `AITO_*_VERSION` pin — the
  marketplace serves the latest release.
- Intensity via `/ponytail lite|full|ultra|off` (default `full`; `PONYTAIL_DEFAULT_MODE`
  or `~/.config/ponytail/config.json` overrides). Extra commands: `/ponytail-review`,
  `/ponytail-audit`, `/ponytail-debt`, `/ponytail-help`.
- ⚠️ Action: none — off by default in `aito setup`. Review its lifecycle hooks after
  install; uninstall with `node scripts/uninstall.js` before removing the plugin.

**Codesight 1.18.0** — AST-based repo map / static wiki (optional).
- Run on demand via `npx codesight --wiki`. No interface change.
- ⚠️ Action: none.

**Graphify 0.17.1** — Code + docs knowledge graph (optional; pick one mapper).
- Run on demand via `npx @sentropic/graphify`. No interface change.
- ⚠️ Action: none.

**Repomix 1.16.0** — One-off repo-to-single-file export with token counts (optional).
- Run on demand via `npx repomix`. No interface change.
- ⚠️ Action: none.

**gh-aw 0.81.6** — Compiles natural-language workflows into GitHub Actions (optional).
- Installed via `gh extension install github/gh-aw`. Still pre-1.0 and fast-moving; keep
  workflows read-only with narrow triggers until piloted.
- ⚠️ Action: none, but re-pilot after upgrades since the schema can shift before 1.0.

**Headroom 0.28.0** — Local AI-traffic compression proxy (opt-in, off by default).
- Installed via `pipx install headroom-ai`. Remains advanced/opt-in: it intercepts and
  caches model traffic, so security-review and pin before routing real traffic.
- ⚠️ Action: none. Stays disabled unless explicitly enabled.

**code2prompt 4.2.0** — Codebase-to-prompt packer (documented alternative to Repomix).
- Documentation reference only; not auto-installed. Installs via `cargo install code2prompt`
  (Rust binary) or npm. (The PyPI `code2prompt` 0.8.x is a separate Python SDK.)
- ⚠️ Action: none.

**LLMLingua 0.2.2** — Prompt compression for custom pipelines (documented, advanced).
- Documentation reference only; not auto-installed. Unchanged upstream since 2024-04.
- ⚠️ Action: none.

### Added (this repo)

- `lib/components/ponytail.sh`: new optional component installing the Ponytail
  minimal-code ruleset plugin (<https://ponytail.dev>) into Claude Code and/or GitHub
  Copilot CLI, with manual slash-command fallback when the host CLI isn't on PATH.
  Wired into the `aito setup` catalog (off by default) and documented in
  `docs/tools.md`, `docs/security.md`, and the README tools table.

### Changed (this repo)

- `lib/components/ccusage.sh`: updated the source URL to `github.com/ccusage/ccusage`
  (project moved orgs as of v20).
- `lib/components/openspec.sh`: added an inline note that v1.5.0's Stores layout is an
  opt-in beta and the default init flow is unaffected.
