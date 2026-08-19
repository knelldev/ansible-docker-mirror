## Status

- Approval: approved for corrected implementation on 2026-08-13.
- Blocker: none.

## Tasks

- [x] Inspect configured Ansible version and callback discovery behavior.
- [x] Align one callback identifier across configuration and plugin metadata.
- [x] Restore callback-owned task and handler source filename prefixes.
- [x] Verify plain task YAML names and safe smoke output remain unchanged.
- [x] Run the normal task-and-handler smoke playbook and capture output.
- [x] Record focused verification evidence and complete required closeout after human validation.

## Verification Evidence

- `ansible-doc -t callback knelldev_default` resolves the repository callback
  with the configured `knelldev_default` identifier.
- `ansible-config dump -t callback knelldev_default --only-changed` confirms
  `result_format = yaml` applies to the custom callback.
- Normal `ansible-playbook playbooks/ping_local.yml` output shows both task and
  handler banners prefixed with `(ping_local.yml)` while task YAML names remain
  plain and result payloads are YAML-formatted.
- The Ansible runtime Python compilation, playbook syntax check, selected
  playbook `ansible-lint`, and `yamllint` pass. `ansible-lint` emits its
  existing incompatible `.yamllint` configuration warning.
- Human validation approved the normal output on 2026-08-13.
- DOX closeout: root `AGENTS.md` now indexes the new
  `callback_plugins/AGENTS.md`; the callback-specific contract records
  discovery, non-verbose smoke, and runtime Python compilation requirements.
- Techstack and user-facing documentation are intentionally unchanged: no
  locked runtime, dependency, or project behavior contract changed.
- The accepted callback behavior is synced to
  `openspec/specs/source-prefixed-ansible-output/spec.md`.

## Next Action

- Archive `repair-ansible-callback` after reviewing the completed change.
