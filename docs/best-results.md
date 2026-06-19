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
| Requirements | **OpenSpec** | building the wrong thing → retries |
| Response style | **Concise instructions** (auto) | verbose output, tool narration |
| Terminal output | **RTK** (explicit mode) | huge diff/test/build logs |
| Evolving context | **ACE playbook** (auto) | re-deriving lessons each session |
| Measurement | **ccusage** + `aito verify` | flying blind on actual usage |

This is exactly what `aito setup` pre-checks. Pick your track(s), accept the defaults,
and you have the baseline. Everything else is added **only on evidence of a specific
problem.**

## Why these five combine well

They're complementary, not redundant — each owns a different waste source (unclear
requirements, verbose responses, noisy tool output, context decay, no visibility). The
biggest lever is **OpenSpec**: avoiding one wrong implementation saves more than
compressing dozens of responses. RTK compresses the *inputs* (often larger than the
model's replies). The ACE playbook keeps the cheap, persistent context improving instead
of being rebuilt. ccusage proves the trend is going the right way.

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
| Agent re-reads many files every task; misses blast radius | **Codesight** *or* **Graphify** | Pick **one**. Codesight for Next.js/TS; Graphify for mixed code+docs+diagrams. Start with the static wiki/graph, not a server. |
| Need an external review or a one-time architecture snapshot | **Repomix** | One-off only. Never attach a full pack to every prompt. |
| A recurring, low-risk repo chore worth automating | **gh-aw** | Later. Read-only first, narrow triggers, approval gates. |
| You want extreme compression in a custom RAG pipeline | **LLMLingua** | Advanced; you own the inputs and measure quality. Not for IDE chat or error/security paths. See [tools.md](tools.md). |

## Project-type quick picks

- **Next.js / TypeScript app:** baseline; if exploration is weak, add **Codesight**.
- **Polyglot / monorepo / lots of docs & diagrams:** baseline; if exploration is weak,
  add **Graphify**.
- **Library / small codebase:** baseline minus mappers — targeted context is already small.
- **Infra / security-heavy:** baseline, but prefer **raw** output (not RTK) for IAM,
  Terraform, and security failures; keep evidence intact.

## Rollout order (don't install everything at once)

1. **Baseline** for a few real features. Watch: retries, unrelated edits, repeated file
   reads, chat length, and `ccusage` totals.
2. **RTK pilot** — confirm explicit-mode compression helps without causing re-fetches;
   only then consider the automatic hook.
3. **One repository map** — add Codesight *or* Graphify *only if* exploration stays a
   problem. Trial one at a time.
4. **Automation** — add gh-aw last, for a clearly recurring task.

Re-run `aito verify` at each step and compare `token-report.md` + `ccusage` trend.

## Combinations to avoid

- **Two repo mappers at once** (Codesight *and* Graphify) — competing, stale-prone maps.
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
