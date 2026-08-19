# DOX

## Purpose

- Defines how contributors and AI agents navigate, change, and verify this repository.

## Core Contract

- Read this file and every applicable child `AGENTS.md` before editing.
- Read applicable `.github/instructions/*.instructions.md` before editing matching source files.
- The nearest `AGENTS.md` owns local contracts; it cannot weaken this file.
- Keep contracts concise, operational, and free of session history.
- Update the nearest `AGENTS.md` only when its durable contract changes.

## Change Records

- `TECHSTACK.md` owns verified runtime, dependency, and quality facts.
- `openspec/specs/` owns accepted technical behavior.
- `openspec/changes/<change-id>/` owns active proposals, designs, tasks, blockers, and verification evidence.
- `docs/decisions/` owns cross-cutting architecture decisions.
- `.ai/recovery/` owns temporary unsafe-state handoffs; `.ai/cache/` and `.ai/scratch/` are ignored.
- Do not duplicate these records in a separate memory or task bank.

## Approval Boundary

- Work explicitly requested and bounded by an existing contract may proceed.
- Ask before adding behavior, dependencies, external services, roles, migrations, security-sensitive changes, or work outside an approved OpenSpec change.
- Use OpenSpec before approved changes that alter behavior across components, integrate external APIs, or change compatibility.
- For OpenSpec-required work, present the proposal and plan for approval before implementation.
- An OpenSpec change is executable only when its proposal records explicit approval and its required planning artifacts are complete.
- One approved plan is primary. Multiple named plans may run together when explicitly approved; record their shared scope and validation in each plan.
- Within approved scope, continue without repeated approval prompts. Stop when scope materially changes.

## Execution Boundary

Plan initialization is planning only. Report once:

- `Plan`: change ID and purpose.
- `Readiness`: planning artifacts and current task status.
- `Approval`: needed, granted, or scope decision needed.
- `Tasks`: concise list of pending tasks and their intended order.
- `Recommended next task`: the smallest task that can proceed.

After plan initialization, ask once for confirmation to execute the selected
plan and listed tasks. Do not edit until that confirmation is granted.

Before implementing the confirmed plan, publish its only compact plan-start record:

- `Plan`: change ID and state in brackets, with task progress when applicable.
- `DOX`: applicable `AGENTS.md` chain only when it clarifies the execution scope.

Then state `Goal`, `Approach`, and `Validation`. Do not include authority. Keep
off-task notes to the smallest useful information.

During the confirmed plan, report only a material result, a changed assumption,
a blocker with the proposed resolution, or an off-chain proposal that asks for
approval. Do not report minor task progress while the goal and side effects are
unchanged. Do not repeat known plan, task, DOX, or validation information.

Do not edit until the work contract identifies bounded authority. Stop and
ask before continuing when an edit, test, or validation would:

- touch an unapproved or non-active change;
- change an approved requirement, design, risk, compatibility promise, or task;
- require an unapproved external system, credential, dependency, privilege, or destructive action; or
- reveal that the active plan is incomplete or incorrect.

For off-chain work or a material task-scope change, report only what differs,
the affected scope, and the decision needed. Ask for approval before proceeding.
Minor implementation details within the approved result do not need reapproval.

When a task finishes, update its OpenSpec status and verification evidence. Report
only a concise implementation result or blocker with relevant evidence and a
decision request. At plan validation, present a table before
changed-file references that states each file and the change it carries.
When every task finishes, request confirmation that the result matches the
expected outcome. After approval, perform DOX closeout, update durable records,
sync or archive the change, and report the clean-state checklist and next work.

## Work Guidance

- Prefer the smallest correct change. Do not invent features or abstractions.
- Start by establishing the requested outcome, applicable contracts, and the smallest safe path. Use OpenSpec when the approval boundary requires a written plan.
- Keep conversation concise: outcome, affected paths, verification, blocker. Use a changed-files table only at plan validation; do not add repeated progress messages.
- Order output for scanning: urgent blocker, failed validation, decision, or
  required user action first; then the current result; then only the stable
  context needed to decide or verify. Omit static context that adds no value.
- Label every completion report as either `Result` (a requested change or decision) or `Validation` (evidence without a behavior change).
- For substantial work, end the final report with a compact standalone `Summary` that begins with exactly one visual state: `🟢 Clear`, `🟡 Follow-up`, or `🔴 Blocked`. Include result, changed paths, completed checks, records updated, open or unexpected points, and one `Next` action. Use bullets or a compact checklist by default; do not force a table. Do not use it for plan initialization or short replies.
- Put the `Summary` first when it contains all useful completion information. Add details before it only when they materially help a reader understand or verify the result.
- Use `🟢 Clear` only when requested work, relevant checks, and required records are complete with no open point. Use `🟡 Follow-up` when usable work has an explicit remaining check, decision, or task. Use `🔴 Blocked` when work needs a decision, approval, credential, or external dependency before it can continue.
- `Next` must be one actionable step, or `None` only when the current plan is complete and needs no archive, sync, or follow-up action.
- `git diff --check` is a patch-hygiene check for whitespace errors that can
  obscure review or break patch application; it does not validate runtime behavior.
- For validation commands and repository scripts, print one copyable outcome
  line before detailed evidence. Reuse that line in the final summary when it
  remains accurate.
- Recommend compaction or a fresh session when the current workstream is complete or the conversation context is becoming costly; preserve the handoff in the canonical OpenSpec or recovery record first.
- Check facts that affect the requested result against repository evidence or authoritative sources. For unrelated details such as loop items, leave them unchanged unless they block the work or reveal a problem; then ask before expanding scope.
- Do not infer requirements, APIs, versions, or behavior from names, conventions, or stale documentation. Inspect source, configuration, tests, or authoritative documentation when the fact affects the requested result.
- Challenge an approach only when a simpler or safer alternative materially reduces risk, complexity, or maintenance.
- Record completed OpenSpec tasks and verification evidence as work progresses.
- Before closeout, re-read the applicable DOX chain, update affected durable contracts, run relevant checks, and report intentional verification gaps.
- Run relevant configured checks. State unrun checks and reasons.
- Before validation, proportionally review requirement coverage, relevant
  repository evidence or authoritative best practices, simpler safe alternatives,
  gaps, regressions, and side effects. Correct in-scope findings; request
  approval for material changes.
- Before sending a substantial final report, remove filler, repeated plan
  context, stale information, and detail that does not help the user decide or
  verify the result.
- Recommend an improvement only when its concrete benefit outweighs added
  distraction or maintenance. State the benefit and request approval before
  expanding scope or changing behavior.

## Child DOX Index

- **.ai/** - Temporary AI research and recovery records.
- **callback_plugins/** - Repository-local Ansible callback plugins and output contracts.
- **docs/** - Durable human-facing project documentation and architecture decisions.
- **roles/** - Ansible role contracts and local verification.
