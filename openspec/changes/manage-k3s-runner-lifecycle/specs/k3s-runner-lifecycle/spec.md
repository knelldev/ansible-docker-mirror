## Purpose

Converge role-owned GitLab instance runners safely by removing stale managed
registrations by default for T-shirt deployments and providing an explicit,
bounded reset and recreation path.

## ADDED Requirements

### Requirement: Complete instance-runner discovery

Before cleanup or reset deletes a runner, the role SHALL retrieve every page of
visible `instance_type` runners and SHALL complete candidate discovery without an
API error.

#### Scenario: Instance runners span multiple pages

- **WHEN** GitLab reports more instance runners than one API page contains
- **THEN** the role SHALL evaluate candidates from every reported page

#### Scenario: Discovery is incomplete

- **WHEN** any required instance-runner page cannot be retrieved or parsed
- **THEN** the role SHALL fail without starting cleanup or reset deletion

### Requirement: Default T-shirt stale cleanup

Stale-runner cleanup SHALL default to enabled when T-shirt generation is enabled
and SHALL remain explicitly disableable. Cleanup SHALL delete only role-owned
`instance_type` runners whose descriptions are absent from the desired runner
set.

#### Scenario: Stale managed T-shirt runner exists

- **WHEN** T-shirt generation is enabled, cleanup is not explicitly disabled, and an owned instance runner is absent from desired state
- **THEN** the role SHALL delete that GitLab runner registration

#### Scenario: Cleanup is explicitly disabled

- **WHEN** the operator sets stale cleanup to false
- **THEN** the role SHALL not delete stale runner registrations

#### Scenario: T-shirt generation is disabled by default

- **WHEN** T-shirt generation is disabled and cleanup is not explicitly enabled
- **THEN** stale cleanup SHALL remain disabled

### Requirement: Dual ownership and type boundary

A runner SHALL be cleanup or reset eligible only when it is `instance_type`, has
the exact configured management tag, and its description starts with the
effective role-owned prefix. With no explicit description prefix, the effective
prefix SHALL cover generated T-shirt descriptions only.

#### Scenario: Project or group runner has ownership-like markers

- **WHEN** a project or group runner has the management tag and matching description prefix
- **THEN** cleanup and reset SHALL preserve it

#### Scenario: Manual instance runner lacks one ownership marker

- **WHEN** an instance runner lacks either the exact management tag or effective description prefix
- **THEN** cleanup and reset SHALL preserve it

#### Scenario: Custom descriptions use compatibility mode

- **WHEN** no explicit description prefix is configured
- **THEN** default cleanup SHALL target generated T-shirt descriptions without treating arbitrary custom descriptions as role-owned

### Requirement: Opt-in managed instance reset

The role SHALL expose a reset flag that defaults to false. When true, it SHALL
remove all owned instance-runner registrations, clear saved values for desired
API-managed instance runners, and recreate desired runners through the normal
registration and deployment flow.

#### Scenario: Reset is disabled

- **WHEN** the reset flag is false
- **THEN** the role SHALL preserve current registrations and saved values except for normal stale cleanup

#### Scenario: Reset is enabled

- **WHEN** the reset flag is true and complete discovery and required credentials are available
- **THEN** the role SHALL remove all owned instance registrations and recreate every desired API-managed instance runner with newly resolved authentication state

#### Scenario: Supplied-token runner exists

- **WHEN** a desired runner uses a supplied authentication token
- **THEN** reset SHALL preserve its registration and saved values

### Requirement: Reset preserves Kubernetes releases

Reset SHALL update existing desired Helm releases through the normal deployment
flow and SHALL NOT delete Helm releases, namespaces, cache data, hook scripts, or
unrelated target-side state.

#### Scenario: Desired runner is recreated

- **WHEN** reset replaces a managed GitLab registration
- **THEN** the existing Helm release SHALL receive the new rendered token without being uninstalled

### Requirement: Reset fails safely without credentials

Reset and enabled cleanup SHALL require the API credential needed to list and
delete instance runners. The role SHALL fail before destructive operations when
that credential is unavailable.

#### Scenario: Reset lacks API credential

- **WHEN** reset is enabled without the required GitLab API credential
- **THEN** the role SHALL fail before clearing saved values or deleting registrations
