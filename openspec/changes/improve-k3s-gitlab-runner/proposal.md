## Why

The K3s GitLab Runner role already deploys disposable, size-tagged runners, but deployment failures are difficult to diagnose and runner ownership is not explicit. The role also lacks simple automatic defaults for multi-node availability, ephemeral disk protection, job-level disk reporting, and optional runner-manager observability.

## What Changes

- Add bounded Helm/Kubernetes readiness checks with runner pod diagnostics on failure.
- Add an optional GitLab API online check when an API token is available.
- Mark every role-created runner with the short `ansible` ownership tag.
- Add opt-in GitLab cleanup for stale runners only when both the ownership tag and role-owned description prefix match.
- Keep Kubernetes resources and manually managed GitLab runners outside automatic cleanup.
- Automatically select one runner-manager replica for one-node clusters and two for multi-node clusters.
- Add soft anti-affinity and a conditional disruption budget when two replicas are selected.
- Add optional per-job ephemeral-storage limits sized automatically from the lowest-node disk capacity, concurrent jobs, and a fixed safety buffer.
- Add disk-related values to the existing resource report and one compact machine-readable metrics line.
- Make hook sampling interval and report thresholds configurable.
- Validate S3 cache Secret handling against the active chart; retain the existing inline cache behavior when the chart cannot consume cache credentials from a Secret.
- Add optional GitLab Runner manager metrics exposure and ServiceMonitor creation.
- Preserve latest Helm chart behavior, T-shirt runner sizing/tags, `run_untagged`, and non-privileged defaults.

## Capabilities

### New Capabilities

- `k3s-runner-operations`: bounded deployment health diagnostics, managed GitLab runner identity/cleanup, automatic runner-manager availability settings, and optional runner metrics.
- `k3s-runner-job-resources`: optional automatic ephemeral-storage limits and improved job-level resource reporting.

### Modified Capabilities

- None.

## Impact

- Affected role: `roles/k3s_gitlab_runner/` and its K3s GitLab Runner playbook.
- Affected systems: GitLab Runner API, GitLab Runner Helm release, Kubernetes runner namespace, and optional Prometheus Operator resources.
- No new mandatory collection, persistent workspace, storage cluster, shared DinD runner, or GitLab Kubernetes Agent is introduced.
- S3 cache remains optional and persistent only through the existing external cache service; its lifecycle remains externally managed.
- Main risks are Helm chart field compatibility, incorrect cleanup targeting, and disk-limit values that are too restrictive; defaults will preserve current behavior where practical.
- Simpler alternatives considered: API-only health checks are insufficient for supplied runner tokens and do not prove the Helm pod is running; fixed replica counts and fixed disk limits are less suitable for disposable one-node versus multi-node clusters.

Approval status: proposal accepted for planning; implementation requires explicit approval after review of the complete plan artifacts.
