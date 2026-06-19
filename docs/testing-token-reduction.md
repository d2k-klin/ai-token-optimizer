# Testing & Proving Token Reduction

After `aito setup`, you should be able to *see* that token reduction is in place — not
take it on faith. This guide explains how `aito verify` measures it, how to read the
report, and how to run your own before/after checks.

> Principle (from the source concept): **judge success by delivery outcomes** — fewer
> retries, less irrelevant context, fewer wasted requests — **not by a single advertised
> percentage**, and never let token savings override evidence (exact errors, security
> warnings, acceptance criteria).

## Quick check

```bash
aito verify      # writes ./token-report.md and prints a PASS/WARN summary
aito doctor      # lighter health check: files present, within budget, tools available
```

`verify` exits non-zero if any gate raises a warning, so it is CI-friendly:

```bash
aito verify || echo "review token-report.md"
```

## The token counter

`aito` counts tokens with the best method available, named at the top of every report:

- **`tiktoken`** — exact counts, used when `python3` and the `tiktoken` package are
  present (`pip install tiktoken`).
- **`estimate`** — a `chars / 4` heuristic fallback, clearly labeled. Good for relative
  before/after comparisons even without `tiktoken`.

Override the conciseness budget with `AITO_INSTRUCTION_BUDGET` (default `1500`).

## The four gates in `token-report.md`

### 1. Instruction conciseness gate
`.github/copilot-instructions.md` and `CLAUDE.md` are re-sent on nearly every
interaction, so their size compounds. Each must stay under the token budget.
**PASS** if within budget; **WARN** (and a non-zero exit) if not — trim it.

### 2. RTK terminal-output compression  *(the headline number)*
Runs read-only commands (`git diff`, `git status`, `git log --stat`) **raw vs through
`rtk`** and reports the token delta and percent reduction per command, plus the total
tokens saved.

- Requires RTK installed (select it in `aito setup`).
- If the working tree is clean there's nothing noisy to compress — the report says so;
  re-run after a real diff/build/test (see "Get a real RTK number" below).

### 3. Targeted context vs whole repository
Compares the whole-repo token count (tracked text files, capped at 5 MB) against just
the persistent artifacts you'd actually load for a task. Demonstrates the payoff of
**lazy/targeted context** instead of dumping the repo into the model. On a small repo
there may be no net saving yet; the gap grows with codebase size.

### 4. Persistent-artifact footprint
Totals the tokens held in durable files (`copilot-instructions.md`, `CLAUDE.md`,
`ai-playbook.md`, `openspec/config.yaml`). These replace ad-hoc chat re-explanation —
over *N* focused sessions they avoid roughly *N×* that re-explanation cost, while keeping
decisions reviewable in git.

The report closes with a **Verdict** (PASS / WARN).

## Get a real RTK number

RTK only helps when there is noisy output to compress. To see a concrete reduction:

```bash
# 1) make sure RTK is installed (via `aito setup`, or)
npm install -g rtk

# 2) generate some noise, then measure
git diff > /dev/null           # or run your test/build so there is output
aito verify
```

Then open `token-report.md` → section 2. You can also compare by hand:

```bash
git diff      | wc -c     # raw bytes (≈ chars; tokens ≈ chars/4)
rtk git diff  | wc -c     # compressed
```

## A manual end-to-end sanity check

```bash
# in a throwaway copy of a project
AITO_ASSUME_YES=1 aito setup
aito verify
sed -n '/## Verdict/,$p' token-report.md
```

You should see the instruction files PASS the conciseness gate and a footprint total in
the low thousands of tokens — i.e. a small, persistent context replacing repeated
explanation.

## What "success" looks like

- Instruction files stay small and PASS the budget gate.
- Noisy command output is materially smaller through RTK than raw.
- You load targeted context (spec + affected files), not the whole repo.
- Decisions live in OpenSpec / `CLAUDE.md` / the playbook, not buried in chat history.
- Over time: fewer implementation retries, fewer unrelated file reads, shorter sessions.

For the underlying techniques behind each of these, see [tools.md](tools.md).
