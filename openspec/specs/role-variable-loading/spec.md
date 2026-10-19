## Purpose

Ensures affected Ansible roles load their common internal application variables
through the standard role variable entry point during normal execution.

## Requirements

### Requirement: Common role variables load by default

Each affected role SHALL expose its required common internal variables through
the standard Ansible role variable entry point during a normal role run.

#### Scenario: Role task references a common variable

- **WHEN** a role task references its existing `app_name`, `app_path`, or
  `app_user` variable
- **THEN** the variable is available without an additional include task

### Requirement: Current values remain unchanged

The repair SHALL preserve the existing values of the moved common variables.

#### Scenario: Existing role execution

- **WHEN** a playbook runs an affected role with its current inputs
- **THEN** it receives the same common variable values as before the nested-file
  refactor
