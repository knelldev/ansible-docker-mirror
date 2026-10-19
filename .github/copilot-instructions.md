# AI Collaboration

This file is a thin client adapter. The repository uses the upstream DOX and
OpenSpec frameworks without redefining them here.

## Framework Boundaries

- DOX is always mandatory. It governs path ownership, applicable contracts, and
  the required documentation pass. Read every applicable `AGENTS.md` chain
  before editing and re-check every affected chain at closeout.
- OpenSpec governs material technical intent, traceability, observable
  requirements, and verification. Use its standard layout and lifecycle.
- A change may affect multiple independent DOX chains and contain multiple
  independent OpenSpec specs. Keep each chain and spec scoped to its own
  responsibility; do not force unrelated work together.
- This steering layer only explains how the two frameworks are combined. It
  must not weaken, replace, or duplicate their core rules.

## Record Ownership

- `AGENTS.md` files own DOX contracts and directory boundaries.
- `TECHSTACK.md` owns verified technology, dependency, runtime, quality, and
  architecture facts.
- `openspec/specs/` owns accepted technical behavior.
- `openspec/changes/<change-id>/` owns active proposals, designs, tasks,
  blockers, and verification evidence.
- `docs/decisions/` owns durable cross-cutting architecture decisions.
- Role and domain `README.md` files own user-facing usage documentation.
- Do not create a separate plan, task bank, or memory record when one of these
  canonical owners applies. Bank useful out-of-scope ideas in the active change
  or final summary, then obtain approval before implementing them.

## Guidance Layers

- Load the matching reusable workflow, reasoning, response-style, Python, and
  Ansible instructions in `.github/instructions/`. They own the project-specific
  classification, approval, execution, validation, and closeout details.
- Keep technology facts in `TECHSTACK.md`, not in reusable AI guidance.
- Keep framework-specific rules in DOX and OpenSpec files; do not copy them
  into every client adapter.
