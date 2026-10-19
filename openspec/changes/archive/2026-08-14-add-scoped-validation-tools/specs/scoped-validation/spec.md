## Purpose

Provide repeatable repository validation that keeps normal terminal output
short while retaining enough local evidence to diagnose any failed check.

## ADDED Requirements

### Requirement: Explicit validation scope

The repository SHALL provide a validation entry point that accepts exactly one
explicit scope: a named playbook, a named role, or the complete repository.

#### Scenario: Playbook validation

- **WHEN** an operator requests validation for a playbook path
- **THEN** the entry point runs every applicable configured check for that
  playbook and reports the resulting status

#### Scenario: Invalid scope

- **WHEN** an operator supplies an unsupported scope or missing target
- **THEN** the entry point exits non-zero and prints concise usage guidance

### Requirement: Concise aggregated result

The validation entry point SHALL run all applicable selected checks before
reporting a final grouped pass/fail summary.

#### Scenario: Selected checks pass

- **WHEN** every applicable selected check succeeds
- **THEN** the final output identifies the scope and reports success

#### Scenario: Selected checks fail

- **WHEN** one or more applicable selected checks fail
- **THEN** the final output identifies each failed check, its target, and the
  location of retained detailed output, then exits non-zero

### Requirement: Local validation evidence

The validation entry point SHALL retain detailed output for each selected check
in an ignored local location.

#### Scenario: Failure investigation

- **WHEN** a selected check fails
- **THEN** its complete command output remains available locally without being
  added to version control
