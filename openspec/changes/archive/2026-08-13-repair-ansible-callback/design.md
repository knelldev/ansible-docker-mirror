## Context

The callback filename, `stdout_callback` setting, `DOCUMENTATION.name`, and
`CALLBACK_NAME` must resolve to one Ansible plugin identifier.

## Design

- Inspect Ansible callback discovery behavior for a local callback file.
- Select the identifier implied by the supported discovery mechanism.
- Align configuration and plugin metadata to that identifier.
- Override the inherited default callback's task-start hook after it assigns the
  display name, then prefix that display name with the filename extracted from
  Ansible's task `path:line`.
- Do not change task YAML names, introduce task variables, or customize verbose
  output. Extend the default callback's result-format documentation fragment so
  the configured YAML result formatter applies to this callback.
- Keep the local smoke playbook suitable for captured output by gathering only
  minimal facts and printing an explicit allowlist rather than `ansible_facts`.

## Verification

- Run a local playbook that starts at least one task and one handler.
- Confirm callback loading and normal captured output contain a source-filename
  prefix for both task and handler banners, without callback-added quotes.
- Run Python syntax validation.
