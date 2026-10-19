## Why

Repeated ad-hoc quality commands produce long, inconsistent output and make it
easy to omit relevant checks. The repository needs a small quality
entry point that gives an operator a concise result while preserving complete
failure evidence locally.

## What Changes

- Add reusable repository-wide quality tooling for recurring formatters, linters,
  and static checks.
- Aggregate configured quality checks and report concise grouped failures after
  all applicable checks finish; retain complete failure output in local logs
  rather than printing it to the terminal.
- Print one copyable outcome line before detailed grouped evidence so humans,
  automation, and plan summaries can reuse the verified result.
- Write detailed command output to an ignored local location and return a
  non-zero status when any selected check fails.
- Make the check list straightforward to extend when a recurring quality or
  test gate would save time or output tokens; do not add one-off wrappers.
- Do not add dependency-update automation in this change; assess it separately
  after the validation interface is proven.

## Capabilities

### New Capabilities

- `repository-quality`: Repeatable repository quality validation with concise
  terminal summaries and retained local logs.

### Modified Capabilities

- None.

## Impact

- New repository-owned validation script(s), ignored local logs, documentation,
  and OpenSpec records.
- No target-host automation behavior, external service, or new runtime
  dependency.

## Risks And Alternatives

- A POSIX shell entry point is the smallest dependency-free option. A Python
  tool or task runner adds maintenance and dependency surface without a current
  need.
- A single recurring repository run avoids ambiguous scope inference.
- Approval status: implementation approved on 2026-08-13. Global, recurring
  quality and test scripts are allowed when they avoid redundant work.
