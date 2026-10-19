## Why

The repository needs one portable, evidence-first AI workflow that works with
OpenCode and GitHub Copilot without duplicating planning, technical facts, or
session state.

## What Changes

- Define DOX, OpenSpec, Techstack, ADR, and temporary-material ownership.
- Keep OpenSpec and its generated client integrations in their standard layout.
- Add concise shared workflow, reasoning, and response-style layers.
- Ignore generated Ansible and AI working artifacts.
- Keep one primary approved plan while allowing explicitly approved concurrent
  plans with traceable shared scope.
- Make plan-start, validation, outcome approval, and closeout concise and
  distinct.
- Use a compact, visually clustered plan-start record with plan state, optional
  task progress and DOX chain, followed by goal, approach, and validation.
- Require validation tools and scripts to print a one-line copyable outcome
  before detailed evidence for reuse in plan summaries.
- Make AI responses urgency-first, scan-friendly, and free of repeated static
  context.
- Require a proportional pre-validation review for requirement coverage,
  applicable best practices, gaps, side effects, and simpler alternatives.
- Limit in-plan output to material results, blockers, or off-chain proposals;
  require approval before adopting a beneficial but out-of-scope improvement.
- End substantial work with validation evidence and a minimal closeout checklist.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- None.

## Impact

- `AGENTS.md`, `.github/`, `.opencode/`, `openspec/`, `.ai/`, and ignore rules.
- No automation runtime behavior changes.

## Alternatives And Risks

- A separate memory or task bank was rejected because it would duplicate
  OpenSpec and ADR records. Observations approved during work are banked in the
  active governance change instead.
- Root-level OpenSpec is retained because it is the official CLI layout.
- A mandatory detailed retrospective was rejected because it duplicates
  OpenSpec evidence and makes routine work slower to scan.
- Numeric priority scoring was rejected because false precision does not improve
  a reader's decision; urgency and required action are stated plainly instead.
- Autonomous process or scope changes were rejected: recommendations remain
  approval-gated even when they appear beneficial.
- Approval status: approved for planning and governance setup; implementation is limited to repository tooling.
