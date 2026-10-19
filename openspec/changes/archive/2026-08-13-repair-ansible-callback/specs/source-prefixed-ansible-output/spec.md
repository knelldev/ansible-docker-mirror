## ADDED Requirements

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
