## Status

- Approval: retain `playbooks/`; no repository inventory default; no root compatibility wrappers.
- Blocker: external Semaphore callers remain outside repository visibility and will be notified separately.

## Tasks

- [x] Inventory playbook references in repository documentation, CI, container configuration, and repository-local Semaphore references.
- [x] Confirm the repository has no committed inventory and no local caller requiring root playbook paths.
- [x] Present and receive the retain decision with explicit breaking compatibility policy.
- [x] Implement the approved layout decision in configuration and documentation.
- [x] Run syntax checks through selected paths without a repository inventory.
- [x] Update documentation after runtime paths are final.

## Verification Evidence

- `ansible-config dump --only-changed` resolves `PLAYBOOK_DIR` to the repository `playbooks/` directory.
- `playbooks/ping.yml` syntax check passes with only the expected no-inventory warning.
- Root `ping.yml` is absent by design; no compatibility wrapper is provided.
- No repository-local Semaphore template or direct playbook caller was found.

## Next Action

- Notify external Semaphore users of the canonical `playbooks/<name>.yml` paths.
