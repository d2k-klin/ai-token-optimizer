# Best Results — which tools to combine, and how

There's no single switch for token efficiency; the wins come from **layering a few tools
that each attack a different source of waste** and not stacking ones that overlap. This
guide gives a recommended baseline, track-specific recipes, project-type tweaks, a
rollout order, and the combinations to avoid.

> Golden rule: **specify clearly → review before coding → implement one task at a time →
> load only relevant context → compress noisy output carefully → keep responses concise →
> verify independently → archive the decision.** Tools support that loop; they don't
> replace it.

## The recommended baseline (start here)

Works for both Copilot and Claude Code, on almost any project:

| Layer | Tool | Source of waste it removes |
|---|---|---|
| Repository knowledge | **OpenWiki** | repeated architecture rediscovery |
| Requirements | **OpenSpec** | building the wrong thing → retries |
| Response style | **Concise instructions** (auto) | verbose output, tool narration |
| Terminal output | **RTK** (explicit mode) | huge diff/test/build logs |
| Evolving context | **ACE playbook** (auto) | re-deriving lessons each session |
| Measurement | **ccusage** + `aito verify` | flying blind on actual usage |

`aito setup` pre-checks Caveman, Ponytail, and OpenWiki by default; OpenSpec, RTK, and
ccusage are one checkbox tick away, but you must select them explicitly to get this
baseline. OpenWiki's scheduled GitHub Action remains a separate opt-in. Everything beyond
this baseline should be added **only on evidence of a specific problem.**

For a new project, apply the baseline immediately after the application scaffold so its
instructions and playbook exist before the first AI-assisted change. For an established
repository, start with the defaults and add optional tools gradually as actual waste
becomes visible.

## Why these layers combine well

They're complementary, not redundant — each owns a different waste source (unclear
requirements, architecture rediscovery, verbose responses, noisy tool output, context
decay, no visibility). The biggest lever is **OpenSpec**: avoiding one wrong
implementation saves more than compressing dozens of responses. OpenWiki keeps
repository knowledge reusable; RTK compresses the *inputs* (often larger than the
model's replies). The ACE playbook keeps cheap persistent context improving instead of
being rebuilt. ccusage proves the trend is going the right way.

## Retrieval comes before compression

Before compressing a 20,000-token file exploration, avoid loading it:

| Need | Start with |
|---|---|
| Exact symbols, references, and code edits | **Serena** |
| Structural call/import/route graph | **Codebase-Memory-MCP** |
| Fuzzy semantic code search and call traces | **grepai** |
| Search across OpenWiki/OpenSpec/ADRs/docs | **QMD** |
| Reuse discoveries from earlier Claude Code sessions | **Claude-Mem** |
| Current external library/API documentation | **Context7** (documented only) |

Use one primary code retriever, then measure whether it reduces file reads. QMD and
Claude-Mem solve separate documentation/session-memory problems and can be added later.

## Track recipes

### GitHub Copilot in VS Code
```
OpenSpec  +  .github/copilot-instructions.md  +  RTK (explicit)  +  ccusage
```
- Use OpenSpec slash commands: `/opsx:propose → review → /opsx:apply → /opsx:verify → /opsx:archive`.
- Keep one focused chat per feature to benefit from Copilot context caching; don't switch
  models mid-session.

### Claude Code in VS Code
```
OpenSpec  +  CLAUDE.md  +  ACE playbook  +  RTK (explicit)  +  ccusage
```
- Lean on the `CLAUDE.md` habits: prompt caching (stable prefix, one model/session),
  `/compact` after a few noisy iterations, scope MCP servers/tools to the task, delegate
  bulk data to code, batch feedback, and select the model by phase.

## Add-ons — only when a specific symptom appears

| Symptom you actually observe | Add | Notes |
|---|---|---|
| Agent opens whole files to find exact symbols/references | **Serena** | Best first retrieval pilot for medium/large codebases. |
| Agent repeatedly reconstructs call graphs/routes/imports | **Codebase-Memory-MCP** | Local deterministic structural graph; verify source for high-stakes answers. |
| Agent needs fuzzy “where is this concept?” search | **grepai** | Use a local embedder unless cloud code transfer is approved. |
| OpenWiki/OpenSpec/docs have become large | **QMD** | Local hybrid retrieval; models use about 2 GB. |
| Claude Code repeats discoveries across sessions | **Claude-Mem** | Persistent session capture; privacy-review before enabling. |
| Agent needs current third-party API docs | **Context7** | Complementary remote service; keep proprietary details out of queries. |
| Need a static/broad repo map | **Codesight** *or* **Graphify** | Codesight for Next.js/TS; Graphify for mixed code+docs+diagrams. |
| Need an external review or a one-time architecture snapshot | **Repomix** | One-off only. Never attach a full pack to every prompt. |
| A recurring, low-risk repo chore worth automating | **gh-aw** | Later. Read-only first, narrow triggers, approval gates. |
| You want extreme compression in a custom RAG pipeline | **LLMLingua** | Advanced; you own the inputs and measure quality. Not for IDE chat or error/security paths. See [tools.md](tools.md). |

## Project-type quick picks

- **Next.js / TypeScript app:** baseline; add **Serena** for symbol work or **Codesight**
  when a static framework-aware map is enough.
- **Polyglot / monorepo / lots of docs & diagrams:** baseline; if exploration is weak,
  pilot **Codebase-Memory-MCP**; use **Graphify** only when non-code material matters.
- **Documentation-heavy project:** add **QMD** after OpenWiki/OpenSpec content grows.
- **Library / small codebase:** baseline minus retrievers/mappers—targeted context is
  already small.
- **Infra / security-heavy:** baseline, but prefer **raw** output (not RTK) for IAM,
  Terraform, and security failures; keep evidence intact.

## Rollout order (don't install everything at once)

1. **Baseline** for a few real features. Watch: retries, unrelated edits, repeated file
   reads, chat length, and `ccusage` totals.
2. **One retrieval pilot** — add Serena, Codebase-Memory-MCP, or grepai only if source
   exploration is costly. Trial one at a time.
3. **QMD or Claude-Mem** — add only when documentation or cross-session rediscovery is
   the measured bottleneck.
4. **RTK pilot** — confirm compression helps without causing re-fetches; only then
   consider the automatic hook.
5. **Automation** — add gh-aw last, for a clearly recurring task.

Re-run `aito verify` at each step and compare `token-report.md` + `ccusage` trend.

## Combinations to avoid

- **Several code retrievers/maps at once** — Serena, Codebase-Memory-MCP, grepai,
  Codesight, and Graphify overlap. Start with one primary tool and add another only for
  a distinct measured gap.
- **Repomix as permanent context** — defeats targeted retrieval; it's a one-off tool.
- **RTK auto-hook before piloting** — can hide evidence or trigger re-fetches.
- **A compression proxy in the IDE path** (Headroom) or **LLMLingua on error/security
  output** — token savings must never override evidence preservation.
- **New chat after every tiny task** — forces context reconstruction; keep one focused
  session, compact it when it goes stale.

## How you'll know it's working

Judge by delivery outcomes, not a headline percentage: features match requirements on the
first try more often, the agent reads fewer unrelated files, sessions stay focused, the
conciseness gate passes, and the **ccusage trend declines**. See
[testing-token-reduction.md](testing-token-reduction.md).
