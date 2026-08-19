## Context

`knelldev_default` obtains each task's source path from Ansible metadata and
adds the filename to normal output. Embedding equivalent information in YAML
task names duplicates that output and makes task definitions less portable.

## Design

- Keep task and handler names as plain, capitalized descriptions of their
  action. Omit quotes unless YAML requires them.
- Remove hardcoded filename prefixes and `task_filename` interpolation. Remove
  redundant quoting where YAML syntax permits it.
- Update the role skeleton alongside existing roles so the contract applies to
  newly generated content.
- Preserve task execution logic and data fields named `name`; only task and
  handler display names are normalized.

## Verification

- Search all role task files and the role skeleton for filename prefixes and
  `task_filename` references.
- Run YAML and Ansible linting for modified content.
- Confirm callback discovery and execute the local task-and-handler smoke
  playbook.
