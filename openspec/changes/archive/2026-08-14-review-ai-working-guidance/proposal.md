## Why

The repository has mandatory DOX and OpenSpec frameworks plus reusable AI
guidance, but their relationship, proportional OpenSpec threshold, approval
model, and closeout behavior need one clear project steering layer.

## What Changes

- Keep DOX and OpenSpec close to their standard semantics and layouts.
- Use the AI instruction layer as project steering rather than adding a root
  steering file or modifying framework definitions.
- Define DOX as the always-on path and local-contract boundary.
- Define full OpenSpec artifacts for material technical changes and a
  proportionate lightweight path for small contract-preserving fixes.
- Support multiple applicable DOX chains and independent specs in one change.
- Define stop conditions, hard boundaries, required work, situational work,
  soft preferences, recommendations, approval, task adaptation, and automatic
  validation closeout with uncertainty gates, followed by confirmed durable
  closeout.
- Allow an `Authority` field when it clarifies permission, without requiring it
  when explicit approval and existing contracts already provide that context.

## Scope

- `.github/copilot-instructions.md`
- `.github/instructions/workflow.instructions.md`
- This OpenSpec change's planning and verification artifacts

## Exclusions

- No redesign of upstream DOX or OpenSpec.
- No root `STEERING.md`.
- No automation runtime, dependency, CI, or deployment behavior changes.

## Risks And Alternatives

- Steering can drift into duplicated framework rules. Keep the adapter focused
  on composition and project decisions, while framework-specific rules remain
  in their owners.
- A strict OpenSpec threshold can create overhead for trivial work. Use the
  material-boundary test and default to OpenSpec when uncertain.
- Automatic closeout can hide incomplete work. Require a stop gate for any
  unresolved question, failed check, unexpected path, incomplete record, or
  material risk.
- A separate steering file was rejected because it is not reliably autoloaded.
- A custom approval field in `.openspec.yaml` was rejected to keep OpenSpec
  metadata close to its standard form; approval remains recorded in the
  proposal and task record.

## Approval

- Approved by the user in-session on 2026-08-14 for implementation within the
  stated scope.
