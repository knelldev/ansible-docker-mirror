## Purpose

Provides predictable, repository-local Ansible execution defaults that remain
compatible with the source collection, its roles, and its custom output.

## ADDED Requirements

### Requirement: Repository-local Ansible execution

The runtime configuration MUST resolve the repository inventory, playbook,
role, collection, callback, log, and Galaxy role-skeleton paths without
requiring machine-specific absolute paths.

#### Scenario: Execute from the repository

- **WHEN** an Ansible command runs with the repository configuration selected
- **THEN** repository-local roles, callbacks, playbooks, and installed
  collection dependencies are discoverable from relative paths

### Requirement: Fact compatibility and bounded gathering

The runtime configuration MUST NOT globally restrict gathered facts below the
normal default set required by the roles, and playbooks MUST be able to opt
into smaller fact subsets for targeted operations.

#### Scenario: Run an OS-aware role

- **WHEN** a role selects variables or sizes work using distribution, mount,
  hostname, FQDN, or memory facts
- **THEN** those facts remain available under the global configuration

#### Scenario: Run a minimal local smoke test

- **WHEN** a playbook declares a minimal fact subset
- **THEN** the playbook-level subset controls that play without being
  overridden by a global `gather_subset = all` setting

### Requirement: Actionable and efficient connections

The runtime configuration MUST use automatic remote interpreter discovery
without routine discovery warnings, SSH pipelining, and bounded retries for
transient SSH connection failures.

#### Scenario: Connect to a supported host

- **WHEN** Ansible connects to a host with a discoverable Python interpreter
- **THEN** it proceeds without the routine interpreter discovery warning

#### Scenario: Recover a transient SSH connection failure

- **WHEN** an SSH connection fails transiently
- **THEN** Ansible retries the connection up to the configured retry limit

### Requirement: Strict inventory and visible deprecations

The runtime configuration MUST fail when an inventory source cannot be parsed
and MUST leave deprecation warnings visible.

#### Scenario: Inventory source is malformed

- **WHEN** no enabled inventory plugin can parse an inventory source
- **THEN** the Ansible invocation fails rather than silently continuing with a
  partial inventory

#### Scenario: Ansible emits a deprecation warning

- **WHEN** Ansible or a collection emits a deprecation warning
- **THEN** the warning remains visible to the operator

### Requirement: Clean repository quality execution

The repository quality script MUST run Ruff without creating or reading a Ruff
cache.

#### Scenario: Run the Ruff quality checks

- **WHEN** the quality script runs its Ruff autofix and verification commands
- **THEN** both commands disable Ruff cache access

### Requirement: Stable readable output

The runtime configuration MUST preserve the existing custom callback and color
overrides, retain commented color options for future console tuning, and
disable cowsay output.

#### Scenario: Run a normal playbook

- **WHEN** a playbook produces callback output
- **THEN** the repository custom callback and existing `bright blue` verbose
  and `bright gray` debug colors remain active
