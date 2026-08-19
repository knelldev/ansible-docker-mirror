# Documentation

## Purpose

Holds durable human-facing documentation and architecture decisions.

## Local Contracts

- `decisions/` contains ADRs for cross-cutting decisions that affect future changes.
- Do not duplicate active plans, task status, or accepted requirements from OpenSpec.
- Keep documentation aligned with verified repository behavior.

## Work Guidance

- Create an ADR only when a decision has durable cross-change consequences.
- Supersede outdated ADRs rather than rewriting their historical decision.

## Verification

- Verify documented commands, paths, and technical claims against repository evidence.

## Child DOX Index

- **execution.md** - Supported local, container, and Semaphore execution setup.
- **decisions/** - Cross-cutting architecture decisions.
