## Why

Watchtower is present as a standalone role but is not referenced by the
current playbooks. Its lifecycle and supported status are unclear.

## Outcome

Decide whether Watchtower remains supported, is documented as opt-in, or is
removed in a later approved change.

## Scope

- Verify references, role behavior, and operational ownership.
- Decide whether automatic container updates fit the repository contract.
- Define documentation and migration requirements.

## Exclusions

- No role or playbook deletion in planning.

Risks include unexpected updates, rollback difficulty, and orphaned operator
expectations. The safer default is explicit opt-in until ownership is decided.

Approval status: planning only.
