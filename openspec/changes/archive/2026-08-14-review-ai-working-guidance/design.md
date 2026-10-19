## Context

DOX and OpenSpec have different, complementary responsibilities. DOX governs
the path hierarchy and local work contracts. OpenSpec governs approved
technical intent and evidence. Project-specific interaction rules belong in
the AI guidance layer so the framework files remain portable and close to
upstream.

## Design

- Keep `AGENTS.md` responsible for DOX traversal, local ownership, and its
  standard execution boundary.
- Keep `openspec/config.yaml` responsible for OpenSpec project context and
  artifact rules.
- Use `.github/copilot-instructions.md` as a thin adapter for composition,
  classification, approval, and closeout.
- Keep reusable workflow behavior in `.github/instructions/` and technical
  facts in `TECHSTACK.md`.
- Calculate applicable DOX chains per target path. A single change may have
  one-to-many chains and one-to-many independent specs.
- Require full OpenSpec artifacts for material behavior, architecture, risk,
  compatibility, dependency, integration, migration, security, or standard
  changes. Permit a lightweight path for small fixes with an obvious existing
  contract.
- Treat approval as approval of the goal and approach. Permit task adaptation
  while the approved paths, design, risk, and outcome remain stable.
- Treat `Authority` as optional context, not as a substitute for explicit
  approval or applicable contracts.
- Run validation closeout automatically only when checks are complete and no
  uncertainty, unexpected path, unresolved risk, or scope question remains.
  Require final outcome confirmation before durable DOX closeout, OpenSpec
  synchronization, or archival.

## Verification

- Re-read all applicable DOX chains before and after editing.
- Check the guidance layer for duplicate or conflicting instructions.
- Confirm the adapter does not redefine DOX or OpenSpec semantics.
- Validate that approval, task adaptation, multiple chains, independent specs,
  stop conditions, and closeout are all explicit.
- Run `openspec doctor`, `openspec validate`, and `git diff --check` when
  available; report unavailable checks rather than claiming them.
