# Security model

These are architectural risk ratings for the workflow `aito` sets up — not claims that
any project is malicious. The guiding rule: **never let token savings override evidence
preservation** (exact errors, security warnings, and acceptance criteria stay intact).

## Incremental risk by component

| Component | Risk | Main concern |
|---|---|---|
| Concise instruction file | Low | A bad instruction influences every request |
| ccusage (monitor) | Low | Reads local agent logs (incl. prompt text); uploads nothing |
| OpenSpec | Low–medium | Executable CLI; specs may hold sensitive detail |
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
- **Safe non-interactive defaults.** Risky opt-ins (RTK auto hook, Codesight/Graphify
  generation, gh-aw install) default to *off* and require explicit confirmation.
- **Version pinning.** Component installs accept `AITO_*_VERSION` overrides; pin once
  validated. Installs prefer package managers / npm over `curl | bash`.
- **Keep generated context out of VCS by default.** `token-report.md`, `*.bak`,
  `repomix-output.*`, `graphify-out/`, and `.codesight/` are added to `.gitignore`.
- **Secret hygiene.** `aito doctor` flags a tracked `.env`; keep secrets out of any
  prompt, spec, or generated map. Review generated wiki/graph/pack output before commit.
- **Preserve evidence.** Use raw output for security/infra failures or when exact
  ordering or warnings matter; do not rely on compressed IAM/Terraform/security output.

## Off by default (explicit opt-in only)

- **Headroom proxy** — intercepts, transforms, caches, and authenticates AI traffic, and
  its documented path is Copilot CLI (not native VS Code Copilot). It is **off by default**
  and gated behind an explicit warning + confirmation in `aito setup`. Enable it only after
  a dedicated security review, pin the version, keep it on localhost, and never route
  security/infra/error output through it. The default workflow stays proxy-free.
- **Full Caveman install** — the lightweight instruction file gives most of the benefit
  without extra tooling; the full package remains an explicit opt-in.
