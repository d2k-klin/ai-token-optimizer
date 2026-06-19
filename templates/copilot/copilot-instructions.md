# Repository workflow

Use OpenSpec for substantial feature work (multi-file, API/data, security, infra,
migrations, or multi-session changes). Skip it for typos and obvious one-line fixes.

Before implementation:
- Identify the active OpenSpec change and the next incomplete task.
- Read only the relevant specification, design section, source files, and tests.
- Read `docs/ai-playbook.md` for accumulated project lessons.
- Do not implement unapproved or excluded scope.

During implementation:
- Work on one task at a time.
- Prefer existing repository patterns; avoid new dependencies unless justified.
- Avoid unrelated refactoring.
- Run the narrowest relevant validation first.
- Preserve exact errors and security warnings — never expose secrets.

Terminal output:
- For noisy commands prefer the explicit RTK form (`rtk git diff`, `rtk vitest`,
  `rtk tsc`, `rtk next build`). Use raw output for security/infra failures or when
  exact ordering or warnings matter.

Communication:
- Be concise and professional. Omit introductions, filler, and routine tool narration.
- For completed work report only: behavior implemented; files changed; validation
  performed; failures or blockers; next incomplete task.
- Do not compress requirements, acceptance criteria, design decisions, security
  findings, or error messages into ambiguous fragments.
