# Project workflow (token-efficient)

Use OpenSpec for substantial work (multi-file, API/data, security, infra, migrations,
multi-session). Skip it for typos and obvious one-line fixes.

## Before implementing
- Identify the active OpenSpec change and next incomplete task.
- Load lazily: read only the relevant spec/design section, the affected source files,
  and their tests. Do not preload the whole repo, all specs, or every tool.
- Read `docs/ai-playbook.md` for accumulated lessons; propose deltas to it when you
  learn something durable (run `aito learn "<lesson>"` or edit the Lessons section).

## While implementing
- One task at a time; prefer existing patterns; avoid new deps unless justified.
- Avoid unrelated refactoring. Run the narrowest relevant validation first.
- Preserve exact errors and security warnings. Never expose or commit secrets.

## Token discipline
- **Prompt caching:** keep a stable context prefix and stay on one model within a
  focused session so cached context is reused; don't switch models mid-session.
- **Compact deliberately:** after ~3–5 noisy iterations, use `/compact` or start a
  fresh session that loads only the persistent artifacts (spec, design, playbook).
- **Scope tools/MCP:** enable only the MCP servers and tools a task needs — more
  options mean more branches to evaluate and more tokens.
- **Delegate bulk data to code:** when a result exceeds ~100 rows, write a script to
  compute the answer and return only the aggregates, not the raw rows.
- **Batch feedback:** give related corrections in one revision pass, not many small ones.
- **Subagents:** use a bounded subagent for independent verification or a side
  exploration so its noise stays out of the main context.

## Terminal output
- Prefer explicit RTK for noisy commands: `rtk git diff`, `rtk vitest`, `rtk tsc`,
  `rtk next build`. Use raw output for security/infra failures or when exact ordering
  or warnings matter.

## Model selection (by phase)
- Exploration/architecture/verification: strong reasoning model.
- Routine implementation: balanced coding model.
- Simple tests/docs: lower-cost model.
- Escalate on evidence (two failed attempts, security-sensitive logic), not by default.

## Communication
- Concise and professional. Omit filler and routine tool narration.
- For completed work report: behavior implemented; files changed; validation; blockers;
  next task. Never compress requirements, acceptance criteria, security findings, or
  error messages into ambiguous fragments.
