# Security model

These are architectural risk ratings for the workflow `aito` sets up — not claims that
any project is malicious. The guiding rule: **never let token savings override evidence
preservation** (exact errors, security warnings, and acceptance criteria stay intact).

## Incremental risk by component

| Component | Risk | Main concern |
|---|---|---|
| Concise instruction file | Low | A bad instruction influences every request |
| ccusage (monitor) | Low | Reads local agent logs (incl. prompt text); uploads nothing |
| Ponytail (plugin) | Low–medium | Host plugin with lifecycle hooks (runs Node scripts); "least code" bias must not trim validation/security code |
| OpenSpec | Low–medium | Executable CLI; specs may hold sensitive detail |
| Context7 | Low–medium | Remote service receives library names and documentation queries; documented only |
| OpenWiki | Medium | Sends repository context to the configured model provider; generated docs concentrate architecture knowledge |
| QMD | Medium | Local index concentrates selected documentation; first embedding run downloads models |
| Serena | Medium | MCP can retrieve and edit code through language servers; anonymous startup metrics default on |
| Codebase-Memory-MCP | Medium | Scans/indexes code and can modify agent configs, instructions, skills, and hooks |
| grepai | Medium | Local index; cloud embedding mode sends code chunks to the selected provider |
| Claude-Mem | Medium–high | Persists prompts/tool output/code observations and runs hooks plus a local worker |
| RTK (explicit mode) | Low–medium | Filtered output may omit useful details |
| RTK (auto hook) | Medium | Transparently rewrites shell commands — **off by default** |
| Codesight / Graphify | Medium | Scans + persists concentrated architecture context |
| Repomix / code2prompt | Medium | Creates a portable repository snapshot |
| LLMLingua (advanced) | Medium | Transforms prompts — can drop detail; not auto-installed |
| gh-aw | Medium–high | Remote autonomous execution on GitHub events |
| Headroom proxy | High | Intercepts/transforms/caches/authenticates AI traffic — **opt-in, off by default** |

## Controls enforced by `aito`

- **Never clobber.** Existing instruction/settings files are backed up to `*.bak` and
  diff-noted; VS Code settings are deep-merged, not overwritten.
- **Safe non-interactive defaults.** Retrieval/memory additions, RTK auto hook, repository
  maps, gh-aw, and the OpenWiki GitHub Action default to *off*. Headroom, Claude-Mem,
  Codebase-Memory's agent configurator, and full Caveman also require a separate
  confirmation.
- **Version pinning.** npm/PyPI components and RTK accept the documented
  `AITO_*_VERSION` overrides; plugin marketplaces serve their current release.
- **Keep generated context out of VCS by default.** `token-report.md`, `*.bak`,
  `repomix-output.*`, `.graphify/`, `.codesight/`, `.codebase-memory/`, QMD SQLite
  indexes, and grepai's local index are added to `.gitignore`.
- **Telemetry scope.** `aito` has no telemetry. OpenSpec initialization is run with
  `OPENSPEC_TELEMETRY=0`, and the bundled OpenWiki workflow sets
  `OPENWIKI_TELEMETRY_DISABLED=1`. Set the matching variable (or `DO_NOT_TRACK=1`) for
  later manual commands too. `aito` invokes Serena setup with
  `SERENA_USAGE_REPORTING=false`; export it for later Serena launches.
- **Secret hygiene.** `aito doctor` flags a tracked `.env`; keep secrets out of any
  prompt, spec, or generated map. OpenWiki API keys belong in its local configuration
  or GitHub Actions secrets, never tracked files. Prefer local QMD/grepai inference;
  cloud embedding sends selected text/code to the provider. Review generated
  wiki/graph/index/pack output before commit.
- **Preserve evidence.** Use raw output for security/infra failures or when exact
  ordering or warnings matter; do not rely on compressed IAM/Terraform/security output.

## Off by default (explicit opt-in only)

- **Headroom proxy** — intercepts, transforms, caches, and authenticates supported
  coding-agent/model traffic. It is **off by default** and gated behind an explicit
  warning + confirmation in `aito setup`. Enable it only after a dedicated security
  review, pin the version, keep it on localhost, and never route security/infra/error
  output through it. The default workflow stays proxy-free.
- **Full Caveman install** — the lightweight instruction file gives most of the benefit
  without extra tooling; the full package remains an explicit opt-in.
- **OpenWiki GitHub Action** — the CLI is installed by default, but scheduled model
  calls and write/PR permissions are not. The workflow is added only after a separate
  confirmation and uses pinned actions, a pinned OpenWiki version, and telemetry opt-out.
- **Claude-Mem** — session capture, hooks, model-backed summarization, and the local
  worker are installed only after a separate warning and confirmation.
- **Primary code retrieval** — Serena, Codebase-Memory-MCP, and grepai remain optional.
  Start with one; each adds executable tooling and a separate retrieval/index boundary.
