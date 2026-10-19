## Why

The configured production Ansible lint profile reports existing violations,
and role documentation and skeleton contracts are inconsistent across roles.

## Outcome

Define a bounded modernization path for role structure, FQCN usage, variable
naming, idempotence, task naming, metadata, and README completeness.

## Scope

- Prioritize violations by safety and behavior risk.
- Define migration boundaries and per-role verification.
- Align role docs and DOX contracts with actual implementation status.

## Exclusions

- No mass refactor or lint suppression in planning.
- No behavior changes until each role's scope is approved.

Approval status: planning only.
