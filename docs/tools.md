# The Tools — what each one does

`aito` is a **summarized setup of available tools for token optimization during
development**. It doesn't reinvent them; it installs, configures, and wires together
existing projects, with safe defaults. This page explains each tool: what it does, why
it saves tokens, whether it's on by default, and what to watch out for.

Legend: **Default ON** = pre-checked in `aito setup`; **Optional** = off until you pick it.

---

## Core (recommended)

### OpenSpec — persistent spec / requirements / tasks layer · **Default ON**
A lightweight specification layer around a feature. One change holds a proposal,
requirements & scenarios, design decisions, a task list, verification state, and
archived history. For IDE assistants it exposes slash commands (`/opsx:propose`,
`/opsx:apply`, `/opsx:verify`, `/opsx:archive`).

- **Why it saves tokens:** it prevents the single most expensive waste — *building the
  wrong thing*. It replaces repeated chat explanations with persistent files, lets a new
  session recover the approved state, and keeps acceptance criteria visible. Avoiding one
  incorrect implementation saves more than compressing dozens of responses.
- **Use for:** multi-file, API/data, security, infrastructure, migration, or
  multi-session changes. Skip for typos and obvious one-liners.
- **Security:** pin the npm version (`AITO_OPENSPEC_VERSION`); review generated prompt
  files; keep secrets and customer data out of specs. `openspec/` is source material.
- **Config:** `openspec/config.yaml` (concise project context + authoring rules).

### Concise-output instructions ("Caveman-lite") — **Always applied by each track**
A small, manually reviewed instruction block — `.github/copilot-instructions.md` for
Copilot, `CLAUDE.md` for Claude Code — telling the assistant to be concise, work one
task at a time, load context lazily, and preserve exact errors and security warnings.

- **Why it saves tokens:** trims verbose responses and routine tool narration without a
  proxy, while explicitly *not* compressing requirements, acceptance criteria, design
  decisions, security findings, or error messages into ambiguous fragments.
- **Note:** kept short on purpose — these files are re-sent on nearly every interaction,
  so size compounds (the [conciseness gate](testing-token-reduction.md) enforces it).

### RTK — compress noisy terminal output · **Default ON (explicit mode)**
Filters and compresses shell-command output (git, test runners, `tsc`, `next build`,
Docker, Kubernetes, logs) *before* it enters model context.

- **Why it saves tokens:** raw test output, diffs, and build logs are often far larger
  than the model's final explanation — compressing the *input* can save more than
  shortening responses.
- **How `aito` sets it up:** explicit commands first (`rtk git diff`, `rtk vitest`,
  `rtk tsc`, `rtk next build`). The automatic Copilot hook (`rtk init -g --copilot`) is
  **off by default** and only enabled if you explicitly confirm.
- **Caution:** use *raw* output for security/infra failures, unclear test failures, or
  when exact ordering/warnings matter — compression can drop context the model needs.

---

## Monitoring (recommended)

### ccusage — local token-usage & cost monitor · **Default ON**
A fast, local CLI that reads the usage logs coding-agent CLIs already write on your
machine (Claude Code at `~/.claude/projects/`, plus GitHub Copilot CLI, Codex, Gemini
CLI, and more) and turns them into daily / weekly / monthly / per-session token and cost
reports.

- **Why it matters here:** the [verify gates](testing-token-reduction.md) are
  point-in-time checks; ccusage shows the **trend** — it's how you actually watch token
  usage drop over days and weeks as the other tools take effect.
- **Privacy:** local-only. It reads files already on disk and uploads nothing.
- **Run it:** `ccusage` (daily) or `ccusage monthly`; no global install needed
  (`npx ccusage`). Pin with `AITO_CCUSAGE_VERSION`.

---

## The "evolving context" layer (ACE)

### ACE playbook — `docs/ai-playbook.md` · **Always applied**
Inspired by **ACE (Agentic Context Engineering)**: instead of rebuilding context every
session, keep an *evolving playbook* of durable lessons and update it with small additive
deltas. ACE frames this as Generator → Reflector → Curator; `aito learn "<lesson>"` is
the Curator-lite step that appends a deduplicated, dated bullet.

- **Why it saves tokens:** persistent, accumulating lessons mean the assistant re-derives
  less each session. Additive deltas avoid "context collapse," where re-summarizing a
  long context silently drops detail.
- **Pochi-derived habits baked into the Claude track:** compact after a few noisy
  iterations; scope MCP servers/tools to the task (more options = more branches = more
  tokens); isolate competing approaches in subagents; and **delegate bulk data to code**
  — when a result exceeds ~100 rows, compute it in a script and return only aggregates.
- **Claude-guide habits:** prompt caching (stable prefix, one model per session), batch
  related feedback into one revision pass, and pick the model by phase.

---

## Optional repository maps (add only if exploration is weak — pick ONE)

### Codesight — AST-based repo map / wiki · **Optional**
Generates compact, framework-aware codebase context as small topic pages (`auth.md`,
`database.md`, `overview.md`). Best fit: Next.js / TypeScript, route-heavy, ORM-backed,
API-oriented projects.

- **Add it only if** the assistant repeatedly re-reads many files, misunderstands routes
  or models, or misses the blast radius of changes. Start with the static wiki
  (`npx codesight --wiki`), not an MCP server.
- **Security:** scans and persists concentrated architecture context — review before
  committing; generated instructions can conflict with existing ones.

### Graphify — knowledge-graph repo map · **Optional**
Maps code *plus* docs, PDFs, images, and diagrams into a persistent knowledge graph
(`graph.html`, `GRAPH_REPORT.md`, `graph.json`) and answers relationship/architecture
questions without re-grepping.

- **Choose Graphify instead of Codesight** for heterogeneous repos (code + documents +
  infra + diagrams) or graph-style relationship questions. **Pick one mapper, not both.**
- **Security:** the graph reveals high-value relationships; keep output local/private and
  review it; avoid network server modes unless required.

---

## Special-purpose & later

### Repomix — one-off repo export + token counting · **Optional**
Packages repository contents into an AI-friendly file and reports token counts.

- **Use for:** a controlled external review, a one-time architecture snapshot, exporting
  a selected directory, or measuring approximate token size.
- **Do *not*** attach a full Repomix pack to every feature — it defeats targeted context.
  Always inspect output for secrets before sharing.

### gh-aw — GitHub Agentic Workflows · **Optional (later)**
Compiles natural-language workflow definitions into GitHub Actions that run AI agents on
events or schedules (issue triage, stale-doc checks, weekly summaries, policy checks).

- **Different from OpenSpec:** OpenSpec is human-driven planning *in the IDE*; gh-aw is
  event-driven automation *in CI*.
- **Add later, read-only first**, with narrow triggers, safe outputs, and approval gates;
  test in a non-critical repo.

---

## Advanced & alternatives (documented, not auto-installed)

These are genuinely useful but are intentionally **not** wired into `aito setup` — either
they overlap with an included tool, or they transform content in ways that carry the same
evidence-loss risk the project avoids elsewhere. Reach for them deliberately.

### code2prompt — codebase → prompt packer · *alternative to Repomix*
A fast packer (Rust/CLI) that turns a codebase into a single prompt with token counts and
flexible include/exclude filtering. It overlaps with **Repomix** (already selectable),
which also offers tree-sitter `--compress` and per-file token counts. Use whichever you
prefer for one-off exports — **don't run both** as permanent context. `npx code2prompt`
or see <https://github.com/mufeedvh/code2prompt>.

### LLMLingua / LLMLingua-2 — perplexity-based prompt compression · *advanced*
Microsoft Research libraries that compress a prompt up to ~20× by scoring tokens with a
small model and dropping low-information ones. Powerful for RAG and long static prompts.

- **Why it's not auto-installed:** it's a Python library you integrate programmatically,
  not a drop-in for native Copilot/Claude IDE chat, and like Headroom it *transforms*
  content before the model sees it — which can silently drop detail the model needs.
  Keep it out of security/infra/error paths.
- **When to consider it:** a custom pipeline (e.g. your own RAG step) where you control
  the inputs and can measure quality. `pip install llmlingua` ·
  <https://github.com/microsoft/LLMLingua>

### Provider-native levers (no install — just use them)
Often the highest-ROI moves need no tool at all: **prompt caching** (stable prefix, one
model per session — large cache-read discounts), **model routing** by phase
(cheap-first, escalate on failure), and **batch APIs** for background work. These are
baked into the Claude track's `CLAUDE.md` guidance.

## Deliberately excluded

- **Headroom (proxy):** compresses tool outputs/files/RAG/context *before they reach the
  model*, but its documented Copilot path is a local proxy that intercepts, transforms,
  caches, and authenticates AI traffic — the wrong fit for a native VS Code, single-agent
  workflow, and a larger security boundary. Reconsider only after a dedicated security
  review and a move to a supported client.
- **Full Caveman package:** the lightweight instruction file gives most of the benefit
  with no extra tooling. The full package stays an explicit opt-in (`aito setup`).

See the [security model](security.md) for per-tool risk ratings, and
[testing-token-reduction.md](testing-token-reduction.md) for how the savings are measured.
