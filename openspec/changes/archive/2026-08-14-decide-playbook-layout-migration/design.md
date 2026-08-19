## Context

The branch contains a structural move from root playbooks to `playbooks/`.
Inventory is intentionally external and has no repository default.

## Decision Process

1. Inventory current documented commands, CI references, container paths, and
   repository-local Semaphore references.
2. Retain `playbooks/` because Ansible resolves the configured playbook directory
   and no repository-local caller requires root paths.
3. Update supported commands and preserve external-inventory use.
4. Notify external Semaphore users separately; do not add root compatibility wrappers.

## Verification

- Run syntax checks through the selected paths without requiring a committed inventory.
- Verify container and repository-local Semaphore invocation references where configured.
- Confirm no inventory content is committed.
