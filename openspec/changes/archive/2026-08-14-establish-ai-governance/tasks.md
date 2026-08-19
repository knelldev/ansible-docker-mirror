## Status

- Approval: approved for ongoing repository tooling observation and improvement.
- Plan state: ongoing; primary plan may run with explicitly approved concurrent plans.
- Observation bank: validate each approved entry is complete before presentation or finish.

## Tasks

- [x] Define record ownership and approval boundaries in root DOX.
- [x] Add concise workflow, reasoning, and response-style instruction layers.
- [x] Initialize OpenSpec for OpenCode and GitHub Copilot.
- [x] Configure OpenCode LSPs and OpenSpec context.
- [x] Ignore generated Ansible, collection, and AI working artifacts.
- [x] Add a one-change execution boundary and concise start-of-work contract.
- [x] Refine plan initialization, explicit multi-plan approval, result-versus-validation labels, and compact closeout guidance.
- [x] Make substantial-work completion summaries standalone, scan-friendly, and non-tabular by default.
- [x] Add portable visual summary states and one next action for OpenCode CLI and GitHub Copilot Markdown.
- [x] Separate plan initialization, approved task start, task completion, and plan closeout records.
- [x] Replace per-task execution prints with one confirmed plan-start record and an approval gate after plan initialization.
- [x] Define one plan-start record, minimal in-plan reporting, validation evidence, outcome approval, and clean closeout.
- [x] Allow an explicitly approved concurrent plan alongside one primary plan.
- [x] Define in-scope handling for unrelated loop items and data values.
- [x] Define progress updates as concise implementation or blocker notices, with plan validation reserved for outcome review.
- [x] Define a compact, visually clustered plan-start record and the purpose of patch-hygiene validation.
- [x] Define reusable one-line validation and script outcome reporting.
- [x] Require a plan-init check for existing or beneficial recurring quality and test scripts.
- [x] Define urgency-first, scan-friendly output ordering; a single plan-start
      record; minimal in-plan reporting; validation closeout; and approval-gated
      improvement recommendations.
- [x] Require a proportional pre-validation quality review for requirement
      coverage, relevant best practices, simpler alternatives, gaps, regressions,
      and side effects.
- [x] Rebuild `TECHSTACK.md` from repository evidence after runtime recovery.

## Verification Evidence

- `openspec doctor` reports an OpenSpec root.
- `openspec validate --specs` reports no specifications to validate.
- `git diff --check` passes.
- Governance contract distinguishes plan initialization from approved execution and makes multi-plan work an explicit opt-in.
- Completion guidance separates the standalone summary from optional supporting detail.
- Summary states use Unicode markers because Markdown clients do not provide portable color control.
- Task starts identify the approved plan, state, applicable task progress, and
  clarifying DOX chain once, followed by goal, approach, and validation.
- Plan initialization lists pending tasks for one user confirmation; later prompts are reserved for material findings, scope changes, or blockers.
- Approved observation: use exactly one plan-start record containing plan state,
  applicable task progress, an optional clarifying DOX chain, goal, approach,
  and validation. Do not include authority, archive detail, or repeated context.
- Approved observation: plan validation presents a file-and-change table before changed-file references; outcome approval precedes closeout.
- Approved observation: leave unrelated loop items and data values unchanged unless they block the result or reveal a problem requiring scope approval.
- Approved observation: do not inspect unrelated task internals once the plan,
  DOX chain, and expected result are clear. Report only a concise implementation
  result or a blocker with relevant evidence and a decision request. Validate
  with the user before closeout.
- Approved observation: state the bounded plan before a broad edit so the user
  can identify an overbroad interpretation before it is applied.
- Approved observation: the one plan-start record uses plan/state in brackets,
  task progress when applicable, and DOX only when it clarifies scope. A blank
  line separates those from goal, approach, and validation. Omit authority.
- Approved observation: `git diff --check` is patch-hygiene evidence only; it
  detects whitespace errors, not implementation behavior.
- Approved observation: validation commands and repository scripts print one
  copyable outcome line before detailed evidence. Reuse the same line in the
  final summary when it is still accurate.
- Approved observation: order output by urgent action, then current result,
  then only stable context needed to decide or verify. Do not rely on numeric
  priority scores or decorative formatting.
- Approved observation: after the single plan-start record, report only material
  result, blocker with proposed resolution, or an off-chain proposal asking for
  approval. Do not print minor task changes when the goal and side effects are
  unchanged.
- Approved observation: before validation, proportionally check requirement
  coverage, relevant best practices, simpler safe alternatives, gaps,
  regressions, and side effects. Fix in-scope findings and request approval for
  material changes.
- Approved observation: substantial-work closeout contains validation evidence
  and a minimal checklist, then self-reviews away repetition, filler, stale
  context, and low-value detail.
- Approved observation: at plan initialization, check whether a recurring
  quality or test script already exists or would materially reduce repeated work.
  Add global recurring gates when beneficial; do not create one-time wrappers.
- `TECHSTACK.md` v1.1.0 records the observed local Ansible 14.3.0 / core 2.21.3,
  ansible-lint 26.8.0, yamllint 1.38.0, and Python 3.14.7 versions; repository
  dependency, collection, CI, quality, and packaging claims were reconciled
  against configuration and scripts on 2026-08-13.
- Approved observation: creating or improving a global recurring quality/test
  script is allowed off-plan when beneficial; implementation still needs a
  clear bounded result and must be validated before closeout.

## Next Action

- Continue observing active work and bank approved governance improvements.
