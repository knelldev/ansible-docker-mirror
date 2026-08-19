## Why

The branch moves root playbooks into `playbooks/`. Existing commands,
Semaphore templates, and documentation may depend on the current locations.

## What Changes

- Retain `playbooks/` as the canonical playbook location.
- Remove the repository inventory default; inventory is always supplied externally.
- Document the breaking path change. Root-level compatibility wrappers are out of scope.

## Capabilities

### New Capabilities

- `playbook-layout`: Users can locate and run supported playbooks with external inventory after the selected layout decision.

### Modified Capabilities

- None.

## Impact

- `playbooks/`, `ansible.cfg`, README commands, role guidance, and external Semaphore configuration.

## Alternatives And Risks

- Retaining is a deliberate breaking compatibility change; external callers are notified separately.
- Semaphore task/template automation is a separate long-term plan.
- Approval status: retain decision confirmed by user; implementation is bounded to layout, docs, and records.
