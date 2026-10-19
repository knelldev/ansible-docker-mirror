## Purpose

Provide one repeatable repository-wide quality command that reduces manual
validation work before changes are committed.

## ADDED Requirements

### Requirement: Repository-wide quality command

The repository SHALL provide one command that runs the configured formatting,
lint, syntax, and advisory quality checks across the repository without
stopping at the first failure.

#### Scenario: All checks are run

- **WHEN** a contributor runs the repository quality command
- **THEN** every configured check is attempted and the command reports an
  aggregate result after the checks finish

#### Scenario: A check fails

- **WHEN** one or more required checks fail
- **THEN** the command returns a non-zero status and identifies the failed
  checks

### Requirement: Local quality evidence

The command SHALL retain detailed output for each check in ignored local log
files and SHALL print a concise, copyable result line for the overall run.

#### Scenario: Quality run produces evidence

- **WHEN** the quality command completes
- **THEN** detailed per-check output is available locally and the terminal
  output includes the log location and aggregate result

### Requirement: Formatter-first validation

The command SHALL apply the configured supported formatters before running the
corresponding post-format checks.

#### Scenario: Formatting precedes verification

- **WHEN** the quality command runs
- **THEN** supported formatting fixes run before formatting verification and
  later quality checks

### Requirement: Unavailable and advisory tools

Unavailable tools SHALL produce warnings without failing the run, and checks
designated advisory SHALL not change the command's required-check exit status.

#### Scenario: Tool is unavailable

- **WHEN** a configured tool is not installed
- **THEN** the command records a warning and continues with the remaining
  checks

#### Scenario: Advisory check fails

- **WHEN** an available advisory check fails
- **THEN** the command reports the advisory failure without treating it as a
  required-check failure
