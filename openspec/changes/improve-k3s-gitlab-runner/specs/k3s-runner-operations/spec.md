## Purpose

This capability makes disposable K3s GitLab Runner deployments easier to operate, diagnose, identify, and observe without taking ownership of unrelated Kubernetes resources or manually managed GitLab runners.

## ADDED Requirements

### Requirement: Bounded runner deployment readiness
The role SHALL wait for the configured Helm deployment and runner manager pods to become ready within a configurable timeout. When readiness fails, the role SHALL report the release status, relevant pod state/events, and recent runner manager logs before failing.

#### Scenario: Runner manager becomes ready
- **WHEN** the Helm release completes and the runner manager pod reaches readiness before the timeout
- **THEN** the role SHALL complete successfully

#### Scenario: Runner manager does not become ready
- **WHEN** the release or runner manager pod remains unready until the timeout
- **THEN** the role SHALL fail and include actionable Helm, pod, event, and recent-log diagnostics

### Requirement: Optional GitLab online verification
When an API token is available and online verification is enabled, the role SHALL verify that the API-managed runner is online after deployment. A supplied runner authentication token without a GitLab API token SHALL rely on Kubernetes readiness instead.

#### Scenario: API-managed runner is online
- **WHEN** the runner API reports the managed runner as online within the configured retries
- **THEN** the role SHALL complete successfully

#### Scenario: API-managed runner stays offline
- **WHEN** the runner API reports the managed runner as offline after the configured retries
- **THEN** the role SHALL fail with the runner identity and status available for diagnosis

### Requirement: Explicit managed runner identity
Every runner created by the role SHALL receive the short `ansible` management tag and a role-owned description prefix. User-configured tags SHALL remain additive. Runner jobs SHALL retain the existing `run_untagged` behavior.

#### Scenario: T-shirt runner is registered
- **WHEN** the role creates a T-shirt runner
- **THEN** GitLab SHALL receive the generated size tags plus the `ansible` management tag and a role-owned description

#### Scenario: Custom runner is registered
- **WHEN** the role creates a custom runner
- **THEN** GitLab SHALL receive the user tags plus the `ansible` management tag and a role-owned description

### Requirement: Safe optional stale-runner cleanup
Stale GitLab runner cleanup SHALL be disabled by default. When enabled, the role SHALL delete only runners that have both the exact `ansible` management tag and the role-owned description prefix, and whose descriptions are absent from the desired runners generated from Ansible configuration. The role SHALL NOT delete Kubernetes releases or runners lacking either ownership marker.

#### Scenario: Managed stale runner is found
- **WHEN** cleanup is enabled and a GitLab runner has both ownership markers but is not in the desired configuration
- **THEN** the role SHALL delete that runner

#### Scenario: Manual runner is found
- **WHEN** cleanup is enabled and a runner lacks the management tag or role-owned description prefix
- **THEN** the role SHALL leave that runner unchanged

### Requirement: Automatic runner manager availability
The role SHALL select one runner manager replica for a one-node Kubernetes cluster and two replicas for a cluster with two or more schedulable nodes, unless an explicit override is configured. When two replicas are selected, the role SHALL use soft anti-affinity and SHALL create a disruption budget that preserves at least one ready replica.

#### Scenario: Single-node cluster
- **WHEN** the cluster has one schedulable node and no explicit replica override
- **THEN** the role SHALL deploy one runner manager replica without requiring anti-affinity or a disruption budget

#### Scenario: Multi-node cluster
- **WHEN** the cluster has at least two schedulable nodes and no explicit replica override
- **THEN** the role SHALL deploy two runner manager replicas, prefer different nodes, and preserve one replica during voluntary disruption

### Requirement: Optional runner-manager metrics
The role SHALL support optional GitLab Runner manager metrics exposure. It SHALL create a Prometheus `ServiceMonitor` only when explicitly enabled, and SHALL not require Prometheus or the Prometheus Operator when metrics are disabled.

#### Scenario: Metrics are disabled
- **WHEN** runner metrics are disabled
- **THEN** the role SHALL deploy without a metrics service or `ServiceMonitor`

#### Scenario: Metrics and ServiceMonitor are enabled
- **WHEN** metrics and ServiceMonitor creation are explicitly enabled and the required operator resource is available
- **THEN** the role SHALL expose the runner manager metrics endpoint and create the `ServiceMonitor`
