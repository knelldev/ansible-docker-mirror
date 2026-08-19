# Callback Plugins

## Purpose

- Owns repository-local Ansible callback plugins and their observable output.

## Local Contracts

- Keep callback identifiers consistent across filename, `CALLBACK_NAME`,
  `DOCUMENTATION.name`, and `ansible.cfg`.
- Task and handler YAML names stay plain; callbacks derive display context from
  Ansible task metadata.
- Preserve configured default callback options by extending the matching Ansible
  documentation fragments.

## Verification

- Confirm discovery with `ansible-doc -t callback <name>`.
- Run a local playbook with a task and handler without verbosity.
- Compile changed Python with the Ansible runtime interpreter.

## Child DOX Index

- None.
