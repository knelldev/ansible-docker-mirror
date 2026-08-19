## Status

- Approval: approved for implementation within the recorded scope.
- Plan state: complete; outcome confirmed and change archived.

## Tasks

- [x] Define framework separation, record ownership, and multiple-chain/spec
      handling.
- [x] Define proportional full-OpenSpec and lightweight classification.
- [x] Define boundaries, approval, optional authority, task adaptation, and stop
      conditions.
- [x] Define validation, automatic closeout gates, reporting, and banked ideas.
- [x] Update the Copilot adapter and reusable workflow guidance.
- [x] Run validation and record evidence.
- [x] Review the result for overlap, contradiction, portability, and missing
      project records.

## Verification Evidence

- Approval recorded in `proposal.md` and this file.
- Applicable root DOX chain and all matching instruction files were read before
  editing.
- `openspec doctor` reports the repository OpenSpec root is valid.
- `openspec validate review-ai-working-guidance --type change` passes.
- `openspec validate --specs` passes for all four accepted repository specs.
- `git diff --check` passes.
- Repository-wide `openspec validate --changes` remains blocked by seven other
  active changes; the new change is valid independently.
- Root DOX closeout confirmation was obtained; steering separates automatic
  validation closeout from confirmed durable closeout.
- The adapter remains a thin client layer; reusable workflow guidance owns
  classification, boundaries, approval, and closeout details.

## Closeout

- Outcome confirmation received from the user.
- Delta spec archived and accepted behavior synced to
  `openspec/specs/ai-guidance-composition/spec.md`.
- Parallel runner work was intentionally left outside this change and commit.
