## Why

`ansible.cfg` selects `knelldev_default`, while the callback plugin declares
`file_prefixed_default`. The custom stdout callback may not load as configured.
Its callback-owned source-file prefix was also removed during recovery.

## What Changes

- Choose one callback identifier and use it consistently in configuration and plugin metadata.
- Keep the custom stdout callback active while prefixing normal task and handler
  banners with their source filename.
- Review existing Ansible configuration only for directly related deprecated or invalid callback settings.

## Capabilities

### New Capabilities

- `source-prefixed-ansible-output`: Ansible playbook output identifies the source file for task and handler banners.

### Modified Capabilities

- None.

## Impact

- `ansible.cfg`, `callback_plugins/knelldev_default.py`, and the local smoke playbook.
- Observable playbook output only; no target-host configuration behavior.

## Alternatives And Risks

- Removing the callback would avoid custom-plugin maintenance but is outside the requested scope.
- Passing file paths through task variables or embedding them in task names was
  rejected because Ansible already provides task source paths to callbacks.
- Approval status: approved for corrected implementation on 2026-08-13.
