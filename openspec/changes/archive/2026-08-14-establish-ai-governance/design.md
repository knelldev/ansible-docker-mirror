## Context

AI workflow was previously split across overlapping workflow, persona, and
session files. OpenSpec is now the native change-record framework.

## Design

- `AGENTS.md` defines DOX traversal, approval boundaries, record ownership, and closeout.
- `TECHSTACK.md` remains the future source for verified technical facts and quality gates.
- `openspec/` uses the default `spec-driven` schema and generated integrations.
- `.github/copilot-instructions.md` is an adapter; global workflow, reasoning,
  and response-style instructions stay in separate files.
- `.ai/recovery/` holds exceptional handoffs. Ignored `.ai/cache/`, `.ai/scratch/`,
  and `.ai/.tmp/` hold temporary material.
- `AGENTS.md` owns the concise execution contract: one plan-start record,
  minimal in-plan updates, plan validation with file/change evidence, outcome
  approval, and clean closeout.
- The primary plan may run with explicitly approved concurrent plans. Approved
  governance observations are recorded in this change, not a separate bank.
- The only plan-start record presents plan/state, applicable task progress, and
  an optional clarifying DOX chain before the goal, approach, and validation.
  In-plan updates are implementation or blocker notices; plan validation and
  closeout remain separate.
- Validation commands and repository scripts print a concise copyable outcome
  line before detailed evidence, allowing the final summary to reuse verified
  status without repeating logs.
- Responses order information by immediate user action: blocker, failed
  validation, decision, current result, then stable supporting context. Omit
  information that neither changes the decision nor helps verify it.
- A confirmed plan has one plan-start record. Between start and validation,
  report only a material completed result, a blocker with a proposed resolution,
  or an off-chain proposal that asks for approval. Do not report minor task
  progress while the goal and side effects remain unchanged.
- Before validation, perform a proportional quality review: verify requirement
  coverage, relevant repository or authoritative best practices, simpler safe
  alternatives, regressions, gaps, and side effects. Fix in-scope findings;
  elevate material scope changes for approval.
- Plan validation presents the outcome line and evidence, followed by a minimal
  completion checklist. The checklist confirms outcome review, record updates,
  intentional gaps, and the single next action without restating the plan.
- End substantial work with a short recap containing only the result, evidence,
  affected records, open risk or decision, and one next action. Self-review the
  response before sending it to remove repetition, filler, stale context, and
  low-value detail.
- Recommend improvements only when their concrete benefit exceeds the added
  distraction or maintenance. Explain that benefit and request approval before
  expanding scope or changing behavior.

## Verification

- Validate OpenSpec structure with `openspec doctor` and `openspec validate`.
- Parse OpenCode configuration as JSON.
- Verify generated directories are ignored.
- Validate approved bank entries are complete before presentation or finish.
- Re-read the instruction chain and OpenSpec artifacts for duplicate, conflicting,
  or missing output rules before completing governance updates.

## Decision

- This is a tooling-only change, so no behavior specification is created.
