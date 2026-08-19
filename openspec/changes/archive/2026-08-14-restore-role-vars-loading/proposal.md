## Why

The mixed branch moved common role variables from `vars/main.yml` to nested
files that Ansible does not load automatically. Roles can therefore reference
undefined `app_name` and `app_path` values.

## What Changes

- Restore each affected role's direct `vars/main.yml` entry point.
- Preserve the current variable values and role behavior.
- Do not redesign shared or role-prefixed variable conventions in this change.

## Capabilities

### New Capabilities

- `role-variable-loading`: Roles load their required common internal variables during normal execution.

### Modified Capabilities

- None.

## Impact

- Affected role `vars/` paths and targeted syntax/lint verification.
- No new dependencies or external APIs.

## Alternatives And Risks

- Explicitly including nested variable files would preserve the refactor but adds task-level loading behavior; direct `vars/main.yml` is the smallest compatible repair.
- Approval status: planning only; implementation requires plan approval.
