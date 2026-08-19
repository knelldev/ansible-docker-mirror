# playbook-layout Specification

## Purpose
TBD - created by archiving change decide-playbook-layout-migration. Update Purpose after archive.
## Requirements
### Requirement: External inventory

The repository SHALL not require or configure a committed or localhost inventory
for supported playbook execution.

#### Scenario: Mounted or supplied inventory

- **WHEN** a user supplies inventory through a local path, container mount, or Semaphore
- **THEN** supported playbooks can use that inventory without repository-managed host data

### Requirement: Canonical playbook location

The repository SHALL keep supported playbooks under `playbooks/` and SHALL not
provide root-level compatibility wrappers.

#### Scenario: Built-in playbook execution

- **WHEN** a user runs a supported built-in playbook
- **THEN** the command uses `playbooks/<name>.yml` locally or `/ansible/playbooks/<name>.yml` in the container

### Requirement: Documented playbook invocation

The repository SHALL document the selected supported playbook location and
invocation path.

#### Scenario: New checkout

- **WHEN** a user follows the documented playbook command
- **THEN** the referenced playbook path exists in the selected layout
