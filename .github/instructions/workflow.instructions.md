---
applyTo: "**"
description: "Repository workflow and scope boundaries."
---

# Workflow

- Follow the DOX and approval boundary in `AGENTS.md`.
- Establish the requested outcome, applicable contracts, and smallest safe path before editing.
- DOX always applies. Use full OpenSpec artifacts when work introduces new
  behavior, changes an existing contract, creates material side effects or
  risk, crosses component boundaries, or establishes a non-trivial technical
  design. This includes new features, roles, playbooks, bigger fixes or
  refactors, security work, migrations, integrations, larger dependency,
  collection, CI, service, API, runtime, or project-standard changes.
- A small correction to already-defined behavior may use the lightweight path
  when its expected result, boundary, and validation are obvious. Wording,
  formatting, stale-reference, test-only, and behavior-preserving mechanical
  changes may also use that path. When uncertain, use full OpenSpec.
- Documentation that only corrects or explains existing behavior may use the
  lightweight path. Documentation that establishes or changes behavior,
  architecture, standards, or an operational contract requires full OpenSpec.
- Documentation updates required by an approved implementation belong to that
  change; do not create a separate documentation change unless the documents
  establish additional behavior or a new contract.
- For OpenSpec-required work, plan first, present the proposal and tasks, record explicit approval, then implement only the approved scope.
- Keep plan initialization separate from execution: report plan purpose, readiness, approval, pending tasks, and recommended next task without implying implementation began. Obtain one explicit confirmation before executing the selected plan.
- Before implementation, publish the one compact `AGENTS.md` plan-start record: plan and state in brackets, task progress when applicable, an optional clarifying DOX chain, then goal, approach, and validation. Follow the applicable DOX contract for its exact record.
- One approved plan is primary. Multiple named plans require explicit approval, with their shared scope and validation recorded in every affected plan.
- Record completed OpenSpec tasks and verification evidence as work progresses.
- Update task status and verification evidence when a task finishes, but report
  intermediate work only as a material result, blocker with proposed resolution,
  or off-chain proposal requesting approval. Do not report minor task progress
  while the goal and side effects are unchanged. At plan validation, place a
  file-and-change table before changed-file references. Ask for confirmation that
  the result matches expectations before closeout.
- Before closeout, re-read the applicable DOX chain, update affected durable contracts, run relevant checks, and report intentional verification gaps.
- Ask only for missing information, off-chain work, material scope changes, risks, or approval boundaries; proceed through minor implementation details within scope.
- Do not repeat known plan details during execution. Before validation,
  proportionally review requirement coverage, relevant best practices, simpler
  safe alternatives, gaps, regressions, and side effects. Correct in-scope
  findings; request approval for material changes.

## Boundaries And Approval

- **Stop and ask:** information is missing; the DOX chain is unclear; a path is
  unapproved; required OpenSpec approval or artifacts are missing; the goal,
  design, risk, compatibility promise, dependency, privilege, or external
  system changes; or validation fails without a clear in-scope fix.
- **Hard boundary:** never work outside DOX, implement unapproved material
  behavior, invent features or dependencies, expose secrets, or use destructive
  repository operations.
- **Required:** establish goal, affected paths and chains, OpenSpec level,
  validation, risks, and record ownership before editing.
- **Situational:** update `TECHSTACK.md`, a decision record, a role README,
  broader checks, or independent specs when the change warrants it.
- **Soft preference:** make the smallest correct change, use modern methods when
  beneficial, preserve stable logic, verify facts, and avoid duplicate rules or
  records.
- **Recommendation:** bank useful improvements and request approval before
  expanding scope.

For planned work, present the applicable DOX chain or chains, goal, scope,
exclusions, approach, validation, risks, and open questions. `Authority` may be
included in plan or approval context when permission needs clarification; do not
add it to a framework-required record that excludes it. Approval covers the goal
and approach, not an immutable task list. Tasks may adapt while the approved
goal, design, paths, and risk boundary remain stable.

## Closeout

- **Validation closeout:** run requirement validation, repository defaults, and
  relevant targeted checks automatically when no uncertainty remains. Review
  side effects, regressions, documentation, and DOX coverage.
- **Durable closeout:** after the required final outcome confirmation, complete
  the DOX documentation pass, update affected records, and synchronize or
  archive OpenSpec artifacts when appropriate.
- Stop before either closeout stage for unresolved questions, failed checks,
  unexpected paths, incomplete records, or material unreviewed risk.
- Report implementation, goal, validation, DOX chains and updates, OpenSpec
  status and evidence, documentation and decisions, quality checks, unexpected
  items, banked ideas, and one next action.
