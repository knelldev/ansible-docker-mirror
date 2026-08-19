# Source-Prefixed Ansible Output Specification

## Purpose

Make normal Ansible task and handler output identify its source file without
requiring verbose mode or file data embedded in task definitions.

## Requirements

### Requirement: Configured callback loads

The repository's configured stdout callback SHALL resolve to the custom callback
plugin in `callback_plugins/`.

#### Scenario: Local playbook run

- **WHEN** a playbook runs with the repository `ansible.cfg`
- **THEN** Ansible loads the configured custom stdout callback without a plugin-name error

### Requirement: Callback-owned source prefixes

The custom callback SHALL prefix normal task and handler banner names with the
source filename from the `path:line` Ansible provides, without requiring file
data in YAML task names or variables.

#### Scenario: Task and handler output

- **WHEN** Ansible starts a task or handler loaded from a repository task file
- **THEN** its displayed banner contains `(<filename>)` before its plain
  configured name without callback-added quotes

### Requirement: Plain role task definitions

Repository role task definitions SHALL omit source filenames and
`task_filename` interpolation from their display names because the callback
provides that context.

#### Scenario: Role task definition

- **WHEN** a repository role task is defined
- **THEN** its display name describes the action without a source filename or
  `task_filename` interpolation
