# AI Working Material

## Purpose

Holds temporary AI-assisted research and recovery material.

## Ownership

- Recovery records stay under `recovery/` until their work resolves.
- `cache/` and `scratch/` are ignored temporary material.

## Local Contracts

- `recovery/` records branch state, evidence, risks, and recovery order.
- Do not treat temporary material as project source.
- Move durable contracts to `AGENTS.md`, `TECHSTACK.md`, `openspec/`, or `docs/decisions/`.

## Work Guidance

- Update recovery records when findings or recovery decisions change.
- Remove obsolete recovery records after their work has shipped.

## Verification

- Recovery records must name the branch, merge target, evidence paths, and unresolved risks.

## Child DOX Index

- **recovery/** - Branch recovery handoffs and audit findings.
- **cache/** - Ignored research and tool caches.
- **scratch/** - Ignored temporary working notes.
