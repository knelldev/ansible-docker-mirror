## Purpose

Provide operators with one concise, secret-safe account of automatic selection,
runner lifecycle actions, configuration outcomes, and observed health after a
successful K3s GitLab Runner role execution.

## ADDED Requirements

### Requirement: Successful execution summary

The role SHALL print exactly one deployment summary after all desired runners and
enabled cleanup or reset processing complete successfully.

#### Scenario: Successful role execution

- **WHEN** every selected runner and enabled lifecycle operation completes successfully
- **THEN** the role SHALL print one final summary covering the complete run

#### Scenario: Role execution fails

- **WHEN** runner deployment, lifecycle processing, or a required health check fails
- **THEN** the role SHALL preserve failure diagnostics without printing a misleading successful-run summary

### Requirement: Cluster and lifecycle outcomes

The summary SHALL report schedulable nodes, effective manager replicas, T-shirt
mode, selected and excluded sizes, relevant feature states, cleanup state and
removed count, and reset state and removed count.

#### Scenario: Automatic lifecycle operations run

- **WHEN** T-shirt selection, stale cleanup, or reset is evaluated
- **THEN** the summary SHALL expose the resulting non-secret decisions and counts

#### Scenario: Lifecycle operation is disabled

- **WHEN** cleanup, reset, or T-shirt generation is disabled
- **THEN** the summary SHALL report it as disabled rather than as an empty successful action

### Requirement: Per-runner outcomes

For each processed runner, the summary SHALL report its name, T-shirt or custom
source, identity action, configuration action, observed health, calculated job
capacity when applicable, and requested CPU and memory when available.

#### Scenario: Existing API-managed runner is unchanged

- **WHEN** a saved API-managed runner token and rendered configuration are reused
- **THEN** the record SHALL report identity `reused`, configuration `unchanged`, and only health actually observed by completed checks

#### Scenario: Runner is created and configured

- **WHEN** the role creates an API-managed runner and applies initial managed configuration
- **THEN** the record SHALL report identity `created` and configuration `initial`

#### Scenario: Configuration is changed or forced

- **WHEN** rendered configuration changes or force reinstall is enabled
- **THEN** the record SHALL distinguish `updated` from `forced`

#### Scenario: Health was not checked

- **WHEN** no completed API or Kubernetes health result exists for a runner
- **THEN** the record SHALL report `not checked` rather than infer health

### Requirement: Secret-safe output

The summary MUST NOT expose runner authentication tokens, GitLab API tokens,
rendered Helm values, credential-bearing URLs, or saved secret content.

#### Scenario: Summary contains destructive and registration outcomes

- **WHEN** the role reports created, rotated, reused, reset, or removed runners
- **THEN** output SHALL contain only non-secret identity, classification, and count fields
